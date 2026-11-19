/**
 * clenv: get a "clean environment".
 *
 * clenv is intended to be similar to `env`, with a few key differences:
 * - By default only a handful of "minimal" variables (eg `LANG`, `TERM`, etc)
 *   are preserved in the environment. This can be changed with `-a` (include
 *   all values) and `-i` (include none)
 * - Instead of setting variables via `NAME=value`, variables are set via
 *   the `-v` flag: `-v NAME=value`. Also supplied as a convenience, `-v NAME`
 *   lets you forward environment variables if they're present. You can also
 *   unset variables with `-u NAME`.
 * - Support for regex (if `regex.h` is present): `-m PATTERN` includes all
 *   variables whose name match PATTERN, and `-U` unsets them.
 * clenv also supports some other QoL features (eg `-0`, `-P`, and `-n`); check
 * the usage for more.
 **/

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <sys/stat.h>

#ifdef __has_include
# define HAS_INCLUDE(x) __has_include(x)
#else
# define HAS_INCLUDE(x) 0
#endif

// Two flags (`-m` and `-U`) require that `<regex.h>` be present. This checks
// for that.
#if defined(HAS_REGEX_H) || HAS_INCLUDE(<regex.h>)
# define HAS_REGEX_H
# include <regex.h>
#else
# warning no <regex.h> present; -m and -U disabled
#endif

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
# define NORETURN _Noreturn
#else
# define NORETURN
#endif

/******************************************************************************
 *                              Global Variables                              *
 ******************************************************************************/

// The inherited environment. Never modified; instead `child_environ` is used.
extern char **environ;

// The environment to pass to the child process.
static char **child_environ;
static size_t child_environ_cap; // Capacity for the child environment

// Set to `argv[0]` at program start; used in error messages.
static const char *program_name;

// The alternative `$PATH` to search executables for.
static const char *alt_path;

// Flags that can be set at startup
static int verbose;     // print debug information
static int dry_mode;    // don't actually execute programs
static int null_ending; // separate entries via `\0` not `\n`
static int just_name;   // only print out the name

// The list of "minimal" values that should be forwarded on by default.
// Note that if this is ever modified, it must end in a `NULL`.
static const char *minimal_env[] = { "TERM", "HOME", "SHLVL", "LANG", NULL };

/******************************************************************************
 *                                 Utilities                                  *
 ******************************************************************************/

// The status associated with the program exit.
enum exit_status
{
	// Successful exit
	EXIT_STATUS_SUCCESS = 0,

	// There was a problem with a flag (unknown, invalid regex pattern, etc)
	EXIT_STATUS_BAD_FLAG = 1,

	// Some internal problem happened
	EXIT_STATUS_INTERNAL = 2,

	// An executable was found, but couldn't be run
	EXIT_STATUS_CANNOT_EXECUTE_EXE = 126,

	// When executing a program, it couldn't be found
	EXIT_STATUS_CANNOT_FIND_EXE = 127
};

/**
 * Print an error message to stderr and exit, prefixing it with the program name
 **/
static NORETURN void
die(enum exit_status status, const char *fmt, ...)
{
	fprintf(stderr, "%s: ", program_name);

	va_list vl;
	va_start(vl, fmt);
	vfprintf(stderr, fmt, vl);
	va_end(vl);

	fputc('\n', stderr);
	fflush(stderr);

	exit(status);
}

/**
 * Print out a log message to stderr, if `verbose` is at least `min_level`
 **/
static void
verbose_log(int min_level, const char *fmt, ...)
{
	if (verbose < min_level)
		return;

	fprintf(stderr, "#%s ", program_name);

	va_list vl;
	va_start(vl, fmt);
	vfprintf(stderr, fmt, vl);
	va_end(vl);

	fputc('\n', stderr);
}


/**
 * Returns whether the file is a normal executable file.
 **/
static int
is_executable_file(const char *path)
{
	struct stat st;
	return !stat(path, &st) && S_ISREG(st.st_mode) && !access(path, X_OK);
}

/**
 * Searches `path` for the program `exe`. Returns a path to the first one
 * that's found (and executable), or `NULL` if nothing matched.
 **/
static char *
find_executable_path(const char *exe, const char *path)
{
	verbose_log(2, "Searching for %s in %s", exe, path);

	size_t exe_len = strlen(exe);

	while (*path) {
		// Find the current entry, then increment `path`
		const char *dir = path;
		size_t dir_len = strcspn(path, ":");
		path += dir_len;

		// An empty dir is actually `.`
		if (!dir_len) {
			dir_len = 1;
			dir = ".";
		}

		// Construct the candidate path
		size_t candidate_len = dir_len + exe_len + 2; // 2 for `/` and NUL
		char *candidate = malloc(candidate_len);
		memcpy(candidate, dir, dir_len);
		candidate[dir_len] = '/';
		memcpy(candidate + dir_len + 1, exe, exe_len + 1); // exe_len + 1 for NUL

		// If it's actually executable, we're done!
		if (is_executable_file(candidate))
			return candidate;

		// Not executable, free it.
		free(candidate);
	}

	// Nothing found, return null.
	return NULL;
}

#ifdef HAS_REGEX_H
/**
 * Attempts to compile a regex; if there's a problem with the regex,
 * then the program aborts with the flag mentioned.
 **/
static void
compile_regex(regex_t *re, char flag, const char *pat)
{
	int err = regcomp(re, pat, REG_EXTENDED | REG_NOSUB);

	if (err) {
		size_t err_size = regerror(err, re, 0, 0);
		char *buf = malloc(err_size);
		regerror(err, re, buf, err_size);
		die(EXIT_STATUS_BAD_FLAG, "-%c: bad regex '%s': %s", flag, pat, buf);
	}
}
#endif /* HAS_REGEX_H */

/******************************************************************************
 *                       Interact with the Environment                        *
 ******************************************************************************/

static int
clenv_expand_environ_if_needed(size_t current_size)
{
	if (current_size < child_environ_cap - 1)
		return 0;

	child_environ_cap *= 2;
	child_environ = realloc(child_environ, sizeof(char *) * child_environ_cap);
	return 1;
}

/**
 * Returns the pointer to `child_environ` for the entry with the name `name`.
 * If `name` is not present, returns the last value in `child_environ` (which
 * when dereferenced is NULL)
 **/
static char **
clenv_find(const char *name, size_t name_len)
{
	char **curr_entry;

	for (curr_entry = child_environ; *curr_entry; ++curr_entry) {
		// Fetch the location of the `=` (if one is present)
		char *eql = strchr(*curr_entry, '=');
		if (!eql) continue; // malformed

		// Check to see if the name matches
		size_t curr_entry_name_len = eql - *curr_entry;
		if (curr_entry_name_len != name_len) continue;
		if (strncmp(name, *curr_entry, curr_entry_name_len)) continue;
		return curr_entry;
	}

	return curr_entry;
}

/**
 * Sets the value of `name` to `value` in the environment. The name must be
 * valid (nonnull, nonempty, and cannot have `=`), and the value must be
 * nonnull.
 **/
static void
clenv_set(const char *restrict name, const char *restrict value)
{
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`
	assert(value);

	// Log just the name if `-n` is supplied (for security).
	if (just_name)
		verbose_log(1, "setting:   %s", name);
	else
		verbose_log(1, "setting:   %s=%s", name, value);

	size_t name_len  = strlen(name);
	size_t value_len = strlen(value);

	// Find the entry associated with the name
	char **entry_ptr = clenv_find(name, name_len);

	// It existed, just append the value
	if (*entry_ptr) {
		// Reallocate to have enough size for the new value
		*entry_ptr = realloc(*entry_ptr, name_len + value_len + 2);
		// Copy just the value over
		memcpy(*entry_ptr + name_len + 1, value, value_len + 1);
		return;
	}

	// It didn't exist, expand the environment if needed
	size_t child_environ_len = entry_ptr - child_environ;
	if (clenv_expand_environ_if_needed(child_environ_len))
		entry_ptr = child_environ + child_environ_len;

	// Construct the entry_ptr
	entry_ptr[1] = NULL; // make sure the next one is zero'd out (for reference)
	*entry_ptr = malloc(name_len + value_len + 2);
	memcpy(*entry_ptr, name, name_len);
	(*entry_ptr)[name_len] = '=';
	memcpy(*entry_ptr + name_len + 1, value, value_len + 1); // also copy trailing `\0`
}

/**
 * Removes the value of `name` from the environment, if it's set. The name must
 * be valid (nonnull, nonempty, and cannot have `=`).
 **/
static void
clenv_unset(const char *name)
{
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`

	verbose_log(1, "unsetting: %s", name);

	size_t name_len = strlen(name);

	// Find the value if it's not set
	char **curr_entry;
	for (curr_entry = child_environ; *curr_entry; ++curr_entry) {
		char *eql = strchr(*curr_entry, '=');
		if (!eql) continue; // malformed

		// Check to see if the value matches
		size_t curr_entry_len = eql - *curr_entry;
		if (curr_entry_len != name_len) continue;
		if (strncmp(name, *curr_entry, curr_entry_len)) continue;

		// It matches; free the memory, then shift everything down by one.
		// (Note that we _could_ just swap in the last value, as POSIX
		// guarantees ordering is irrelevant, but I like being able to see which
		// onesare the most recently added lol)
		free(*curr_entry);

		// Shift everything down
		for (; curr_entry[1]; curr_entry++) *curr_entry = curr_entry[1];
		*curr_entry = 0; // zero out the last one
		return;
	}
}

#ifdef HAS_REGEX_H
/**
 * Finds all parameters in the inherited environment whose names match
 * `pattern`, and sets them in the current environment.
 **/
static void
clenv_set_matching(const regex_t *re)
{
	for (int i = 0; environ[i]; ++i) {
		// Find the position of `=`; if it doesn't exist, that's a malformed
		// value and we just ignore it entirely.
		char *eql = strchr(environ[i], '=');
		if (!eql) continue;

		char *name = strndup(environ[i], eql - environ[i]);
		if (!regexec(re, name, 0, 0, 0))
			clenv_set(name, eql + 1);
		free(name);
	}
}

/**
 * Unsets all parameters in the environment whose names match `pattern`.
 **/
static void
clenv_unset_matching(const regex_t *re)
{
	int nmatches = 0, cap = 4;
	char **matches = malloc(sizeof(char *) * cap); // todo: optimize when nothing matches?

	for (int i = 0; child_environ[i]; ++i) {
		// Find the position of `=`; if it doesn't exist, that's a malformed
		// value and we just ignore it entirely.
		char *eql = strchr(child_environ[i], '=');
		if (!eql) continue;

		char *name = strndup(child_environ[i], eql - child_environ[i]);
		if (!regexec(re, name, 0, 0, 0)) {
			if (nmatches == cap)
				matches = realloc(matches, sizeof(char *) * (cap *= 2));
			matches[nmatches++] = name;
		} else {
			free(name);
		}
	}

	for (int i = 0; i < nmatches; ++i) {
		clenv_unset(matches[i]);
		free(matches[i]);
	}
	free(matches);
}
#endif /* HAS_REGEX_H */

/******************************************************************************
 *                               Business Logic                               *
 ******************************************************************************/

// How to setup the initial environment
enum starting_env
{
	// Unset everything except the "minimal" options
	MINIMAL_ENV,

	// Unset everything
	EMPTY_ENV,

	// Unset nothing
	INHERIT_ENV
};

/**
 * Replace `environ` with the initial starting environment, depending on
 * the `starting_env` value.
 **/
static void
setup_initial_env(enum starting_env starting_env)
{
	child_environ_cap = 8;
	child_environ = malloc(sizeof(char *) * child_environ_cap);
	*child_environ = 0;

	// If we inherit the environment, don't change `environ` at all.
	if (starting_env == INHERIT_ENV) {
		verbose_log(2, "inheriting environment");

		// Gotta manually copy it to prevent `clenv -a -u HOME -v HOME` errors
		size_t i = 0;
		for (i = 0; environ[i]; ++i) {
			clenv_expand_environ_if_needed(i);
			child_environ[i] = strdup(environ[i]); // Also have to strdup so modifications dont affect the `-m`, and we can free
		}

		child_environ[i] = NULL;
		return;
	}


	// Clear the environment by setting
	verbose_log(1, "clearing environment");

	// Populate the "minimal environment" before clearing it
	if (starting_env == MINIMAL_ENV) {
		verbose_log(2, "setting up minimal environment");

		for (int i = 0; minimal_env[i]; ++i) {
			char *value = getenv(minimal_env[i]);
			if (value) clenv_set(minimal_env[i], value);
		}
	}
}

/**
 * Prints the environment to stdout, one name per line.
 **/
static void
print_environment(void)
{
	char ending = null_ending ? '\0' : '\n';

	for (int i = 0; child_environ[i]; ++i) {
		if (just_name) {
			char *value;

			// If the value is malformed (ie no `=`) then don't print it.
			if (!(value = strchr(child_environ[i], '='))){
				verbose_log(2, "not outputting malformed env value: %s", child_environ[i]);
				continue;
			}

			fwrite(child_environ[i], value - child_environ[i], 1, stdout);
		} else {
			fputs(child_environ[i], stdout);
		}

		fputc(ending, stdout);
	}
}

/**
 * Executes the program in `argv[0]`, potentially resolving its path first (via
 * a `find_executable_path` lookup). Does nothing if `dry_mode` is set.
 **/
static void
execute_program(int argc, char **const argv)
{
	// Search for the program name if a non-path executable is given
	if (*argv[0] && !strchr(argv[0], '/')) {
		// If no alt path is supplied, check the inherited `$PATH`
		if (!alt_path)
			alt_path = getenv("PATH");

		// If there's still not alt path, fetch the default one.
		if (!alt_path) {
			size_t alt_len = confstr(_CS_PATH, 0, 0);
			alt_path = malloc(alt_len);
			confstr(_CS_PATH, (char *) alt_path, alt_len);
		}

		char *orig = argv[0];
		if (!(argv[0] = find_executable_path(orig, alt_path)))
			die(EXIT_STATUS_CANNOT_FIND_EXE, "%s: No such file or directory", orig);
	}

	// Log what we're executing in verbose mode
	if (verbose) {
		verbose_log(1, "executing: %s", argv[0]);
		for (int i = 0; i < argc; ++i)
			verbose_log(1, "  argv[%d]= '%s'", i, argv[i]);
	}

	// Don't actually run the command in dry mode.
	if (dry_mode)
		return;

	environ = child_environ;
	// execvp not execv, it wont search (argv[0] has `/`), and falls back to
	// `sh` on ENOEXEC
	execvp(argv[0], argv);

	die(errno == ENOENT ? EXIT_STATUS_CANNOT_FIND_EXE :
			EXIT_STATUS_CANNOT_EXECUTE_EXE, "%s: %s", argv[0], strerror(errno));
}

/**
 * Prints the usage and then exits
 **/
static NORETURN void
usage(void)
{
	printf("usage: %s [options] [utility ...]\n", program_name);
	puts("options:");
	puts("\t-h              Print this");
	puts("\t-D              Don't actually run the program; Sets -V");
	puts("\t-V              Print the invocation, and any changed variables.");
	puts("\t-P ALTPATH      Use 'ALTPATH' to find 'utility', instead of $PATH");
	puts("\t-a              Pass all environment variables in by default");
	puts("\t-i              Don't set any variables by default, including \"minimal ones\"");
	puts("\t-0              End lines with NUL (\\0) instead of newline; omit utility");
	puts("\t-n              Print just variable names, instead of their values.");
	puts("\t-v NAME[=VALUE] Puts 'NAME' in the environment of 'utility'. If 'VALUE' is");
	puts("\t                omitted, it uses the current VALUE (or omits unset).");
	puts("\t-u NAME         Unset 'NAME'. Ignores unset names.");
#ifdef HAS_REGEX_H
	puts("\t-m PATTERN      Sets variables that match PATTERN");
	puts("\t-U PATTERN      Unsets variables that match PATTERN");
#else
	puts("\t-m PATTERN      <Not compiled in>");
	puts("\t-U PATTERN      <Not compiled in>");
#endif

	exit(EXIT_STATUS_SUCCESS);
}

/**
 * Parses command line flags out from `argv`, and populates any relevant global
 * variables. Updates `argc` and `argv` to point to the remaining non-flag
 * arguments (if any).
 **/
static void
parse_arguments(int *argc, char ***argv)
{
	struct action {
		char flag;
		union {
			struct arg_value { char *arg, *value; } av;
	#ifdef HAS_REGEX_H
			regex_t re;
	#endif
		} u;
	};

	struct action *actions = malloc(*argc * sizeof(struct action));
	int nactions = 0;

	// Scan the argument list for options which should be processed before
	// any others. (This makes setting up a new environment significantly
	// easier.)
	enum starting_env starting_env = MINIMAL_ENV;
	int option;

	while ((option = getopt(*argc, *argv, "+hDV0P:aniv:u:m:U:")) != -1) {
		switch (option) {
		case 'h':
			usage();

		case 'D':
			dry_mode = 1;
			// fallthrough
		case 'V':
			verbose++; // Repeat multiple times for more specificity
			break;

		case '0':
			null_ending = 1;
			break;
		case 'n':
			just_name = 1;
			break;

		// Set the initial environment: inherited, empty, or minimal (default)
		case 'a':
			starting_env = INHERIT_ENV;
			break;

		case 'i':
			starting_env = EMPTY_ENV;
			break;

		case 'P':
			alt_path = optarg;
			break;

		case 'v':
			if (!*optarg || *optarg == '=')
				die(EXIT_STATUS_BAD_FLAG, "-v: variable name must not be empty");

			char *value;

			// Parse out `-v NAME=VALUE` vs just `-v NAME`.
			if ((value = strchr(optarg, '='))) {
				*value++ = '\0';
			} else if (!(value = getenv(optarg))) {
				verbose_log(1, "-v %s: variable not present, not setting", optarg);
				continue;
			}

			actions[nactions++] = (struct action) {
				.flag = option,
				.u = { (struct arg_value) { .arg = optarg, .value = value } }
			};
			break;

		case 'u':
			if (!*optarg)
				die(EXIT_STATUS_BAD_FLAG, "-u: argument must not be empty");

			if (strchr(optarg, '='))
				die(EXIT_STATUS_BAD_FLAG, "-u: variable name cannot contain an '=': %s", optarg);

			actions[nactions++] = (struct action) {
				.flag = option,
				.u = { (struct arg_value) { .arg = optarg} }
			};
			break;

		case 'm':
		case 'U':
#ifdef HAS_REGEX_H
			actions[nactions].flag = option;
			compile_regex(&actions[nactions++].u.re, option, optarg);
			break;
#else
			die(EXIT_STATUS_BAD_FLAG, "-%c: regex is not compiled into this version of clenv", option);
#endif

		default:
			exit(EXIT_FAILURE);
		}
	}

	*argc -= optind;
	*argv += optind;

	// Make sure mutually-incompatible options aren't given
	if (alt_path && !*argc)
		die(EXIT_STATUS_BAD_FLAG, "cannot supply -P and no executable");
	if (null_ending && *argc)
		die(EXIT_STATUS_BAD_FLAG, "cannot supply -0 and an executable");

	// Setup the initial environment based on the flags that were passed.
	setup_initial_env(starting_env);

	for (int i = 0; i < nactions; ++i) {
		switch (actions[i].flag) {
		case 'v': clenv_set(actions[i].u.av.arg, actions[i].u.av.value); break;
		case 'u': clenv_unset(actions[i].u.av.arg); break;
#ifdef HAS_REGEX_H
		case 'm': clenv_set_matching(&actions[i].u.re); break;
		case 'U': clenv_unset_matching(&actions[i].u.re); break;
#endif
		default: die(EXIT_STATUS_INTERNAL, "bug!");
		}
	}
	free(actions);
}

int
main(int argc, char *argv[])
{
	if (argc == 0) {
		program_name = "clenv";
	} else {
		program_name = strrchr(argv[0], '/');
		if (program_name) argv[0] = strdup(++program_name); // todo: get rid of strdup
		else program_name = argv[0];
	}

	parse_arguments(&argc, &argv);

	if (!argc)
		print_environment();
	else
		execute_program(argc, argv);

	return EXIT_STATUS_SUCCESS;
}
