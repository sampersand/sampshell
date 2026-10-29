#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

#ifndef __has_include
# define __has_include(x) 0
#endif

#if defined(HAS_REGEX_H) || __has_include(<regex.h>)
# define HAS_REGEX_H
# include <regex.h>
#endif

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
# define NORETURN _Noreturn
#else
# define NORETURN
#endif

/******************************************************************************
 *                              Global Variables                              *
 ******************************************************************************/

// Initially the inherited environment, but cleared early on (unless `-a` is
// passed in) to provide a "clean slate" for `setenv` and friends to work on.
extern char **environ;

// Set to `environ` at program start, to have a clean starting environment.
char **inherited_environ;

// Set to `argv[0]` at program start; used in error messages.
const char *program_name;

// The alternative `$PATH` to search executables for.
const char *alt_path;

// Flags that can be set at startup; control program execution and logging.
int dry_mode, verbose;

/******************************************************************************
 *                                 Utilities                                  *
 ******************************************************************************/

/**
 * Print an error message to stderr and exit, prefixing it with the program name
 **/
static NORETURN void
die2(int status, const char *fmt, ...)
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

// Like `die2`, but without specify exit code
#define die(...) die2(EXIT_FAILURE, __VA_ARGS__)

/**
 * Print out a log message to stderr, if the verbose is at least `min_level`
 **/
static void
vlog(int min_level, const char *fmt, ...)
{
	if (verbose < min_level)
		return;

	fputs("#clenv ", stderr);

	va_list vl;
	va_start(vl, fmt);
	vfprintf(stderr, fmt, vl);
	va_end(vl);

	fputc('\n', stderr);
}

/**
 * Searches `alt_path` for the program `exe`. Returns a path to the first one
 * that's found (and executable), or `NULL` if nothing matched.
 **/
static char *
find_executable_path(const char *exe)
{
	vlog(1, "Searching for %s in %s", exe, alt_path);

	char *mpath = strdup(alt_path);
	char *cwd = NULL;

	for (char *entry = strtok(mpath, ":"); entry; entry = strtok(NULL, ":")) {
		// If entry is empty, that's PWD according to posix
		if (!*entry) {
			if (!cwd) getcwd(cwd, sizeof(cwd));
		}
		long size = strlen(entry) + 1 + strlen(exe) + 1;
		char *path = malloc(size);
		snprintf(path, size, "%s/%s", entry, exe);

		if (!access(path, X_OK)) {
			vlog(1, "  matched: %s", path);
			return free(mpath), path;
		}

		vlog(2, "  didn't match: %s", path);
		free(path);
	}

	return free(mpath), NULL;
}

#ifdef HAS_REGEX_H
static void compile_regex(regex_t *re, char flag, const char *pattern) {
	int err = regcomp(re, pattern, REG_EXTENDED | REG_NOSUB);

	if (err) {
		size_t err_size = regerror(err, re, 0, 0);
		char *buf = malloc(err_size);
		regerror(err, re, buf, err_size);
		die("-%c: bad regex '%s': %s", flag, pattern, buf);
	}
}
#endif

/******************************************************************************
 *                                                                            *
 *                       Interact with the Environment                        *
 *                                                                            *
 ******************************************************************************/

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

	vlog(0, "setting:   %s=%s", name, value);

	if (setenv(name, value, 1) == -1) {
		// Note we use `perror` since the error case is very unlikely
		// (memory exhaustion; we already validate the name normally)
		perror(program_name);
		abort();
	}
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

	vlog(0, "unsetting: %s", name);

	if (unsetenv(name) == -1) {
		// Note we use `perror` since the error case is very unlikely
		// (memory exhaustion; we already validate the name normally)
		perror(program_name);
		abort();
	}
}

/**
 **/
static char *clenv_get(const char *name) {
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`

	char *value;

	// We check `errno` here since a return value of `NULL` could also just mean
	// it wasn't found inthe environment.
	errno = 0;
	if (!(value = getenv(name)) && errno) {
		// Note we use `perror` since the error case is impossible (we already
		// validate the name)
		perror(program_name);
		abort();
	}

	return value;
}

#ifdef HAS_REGEX_H
/**
 * Finds all parameters in the inherited environment whose names match
 * `pattern`, and sets them in the current environment.
 **/
void clenv_set_matching(const regex_t *re) {
	for (int i = 0; inherited_environ[i]; ++i) {
		char *eql = strchr(inherited_environ[i], '=');
		if (!eql) die("[bug] no `=` found in environ of %s", inherited_environ[i]);

		char *name = strndup(inherited_environ[i], eql - inherited_environ[i]);
		if (!regexec(re, name, 0, 0, 0)) {
			clenv_set(name, eql + 1);
		}

		free(name);
	}
}

/**
 * Unsets all parameters in the environment whose names match `pattern`.
 **/
static void clenv_unset_matching(const regex_t *re) {
	int nmatches = 0, cap = 4;
	char **matches = malloc(sizeof(char *) * cap); // todo: optimize when nothing matches?

	for (int i = 0; environ[i]; ++i) {
		char *eql = strchr(environ[i], '=');
		if (!eql) die("[bug] no `=` found in environ of %s", environ[i]);

		char *name = strndup(environ[i], eql - environ[i]);
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
#endif

/******************************************************************************
 *                               Business Logic                               *
 ******************************************************************************/

enum starting_env { MINIMAL_ENV, EMPTY_ENV, INHERIT_ENV };

static void setup_initial_env(enum starting_env starting_env) {
	// If we inherit the environment, don't do anything special.
	if (starting_env == INHERIT_ENV) {
		vlog(1, "inheriting environment");
		return;
	}

	// Now take all the "minimal" environment values and forward them through.
	struct { char *name, *value; } minimal_env[] = {
		{ "TERM", 0 }, { "HOME", 0 }, { "SHLVL", 0 }, { "LANG", 0 }, { 0, 0 }
	};

	if (starting_env == MINIMAL_ENV) {
		for (int i = 0; minimal_env[i].name; ++i)
			minimal_env[i].value = clenv_get(minimal_env[i].name);
	}

	// Otherwise, clear the environment by setting a new one.
	vlog(0, "clearing environment");
	environ = malloc(sizeof(char **));
	*environ = NULL;

	// If we're not setting up the minimal env, we're done.
	if (starting_env == MINIMAL_ENV) {
		vlog(1, "setting up minimal environment");
		for (int i = 0; minimal_env[i].name; ++i)
			clenv_set(minimal_env[i].name, minimal_env[i].value);
	}
}

/**
 * Prints the environment to stdout, one name per line.
 **/
static void
print_environment(void)
{
	if (alt_path)
		die("cannot supply an alternative $PATH and no executable");

	for (int i = 0; environ[i]; ++i)
		puts(environ[i]);
}

/**
 * Executes the program in `argv[0]`, potentially resolving its path first (via
 * a `find_executable_path` lookup). Does nothing if `dry_mode` is set.
 **/
static void
execute_program(int argc, char **const argv)
{
	if (verbose) {
		vlog(0, "executing: %s", argv[0]);

		for (int i = 0; i < argc; ++i)
			vlog(0, "  argv[%d]= '%s'", i, argv[i]);
	}

	// Don't actually run the command in dry mode.
	if (dry_mode)
		return;

	if (alt_path) {
		char *orig = argv[0];
		if (!(argv[0] = find_executable_path(orig)))
			die2(127, "%s: No such file or directory", orig);
		execv(argv[0], argv);
	} else {
		execvp(argv[0], argv);
	}

	die("exec of %s failed: %s", argv[0], strerror(errno));
}

/**
 * Prints the usage and then exits
 **/
static NORETURN void
usage(void)
{
	printf("usage: %s [options] [utility ...arguments]\n", program_name);
	puts("options:");
	puts("\t-h              Print this");
	puts("\t-D              Don't actually run the program; Sets -V");
	puts("\t-V              Print the invocation, and any changed variables.");
	puts("\t-P ALTPATH      Use 'ALTPATH' to find 'utility', instead of $PATH");
	puts("\t-a              Pass all environment variables in by default");
	puts("\t-n, -i          Don't set any arguments by default, including \"minimal ones\"");
	puts("\t-v NAME[=VALUE] Puts 'NAME' in the environment of 'utility'. If 'VALUE' is");
	puts("\t                omitted, it uses the current VALUE (or errors if unset).");
	puts("\t-u NAME         Unset 'NAME'. Ignores unset names.");
#ifdef HAS_REGEX_H
	puts("\t-m PATTERN      Sets variables that match PATTERN");
	puts("\t-U PATTERN      Unsets variables that match PATTERN");
#else
	puts("\t-m PATTERN      <Not compiled in>");
	puts("\t-U PATTERN      <Not compiled in>");
#endif

	exit(EXIT_SUCCESS);
}

/**
 * Parses command line flags out from `argv`, and populates any relevant global
 * variables. Updates `argc` and `argv` to point to the remaining non-flag
 * arguments (if any).
 **/
static void parse_arguments(int *argc, char ***argv) {
	struct action {
		char flag;
		union {
			struct { char *arg, *value; };
	#ifdef HAS_REGEX_H
			regex_t re;
	#endif
		};
	};

	struct action *actions = malloc(*argc * sizeof(struct action));
	int nactions = 0;

	// Scan the argument list for options which should be processed before
	// any others. (This makes setting up a new environment significantly
	// easier.)
	enum starting_env starting_env = MINIMAL_ENV;
	int option;
	while ((option = getopt(*argc, *argv, "+hDVP:aniv:u:m:U:")) != -1) {
		switch (option) {
		case 'h':
			usage();

		case 'D':
			dry_mode = 1;
			// fallthrough
		case 'V':
			verbose++; // Repeat multiple times for more specificity
			break;

		// Set the initial environment: inherited, empty, or minimal (default)
		case 'a':
			starting_env = INHERIT_ENV;
			break;

		case 'n':
		case 'i':
			starting_env = EMPTY_ENV;
			break;

		case 'P':
			alt_path = optarg;
			break;

		case 'v':
			if (!*optarg || *optarg == '=')
				die("-v: variable name must not be empty");

			char *value;

			// Parse out `-v NAME=VALUE` vs just `-v NAME`.
			if ((value = strchr(optarg, '='))) {
				*value++ = '\0';
			} else if (!(value = clenv_get(optarg))) {
				die("-v %s: variable is unset", optarg);
			}

			actions[nactions++] = (struct action) {
				.flag = option,
				.arg = optarg,
				.value = value
			};
			break;

		case 'u':
			if (!*optarg)
				die("-u: argument must not be empty");

			if (strchr(optarg, '='))
				die("-u: variable name cannot contain an '=': %s", optarg);

			actions[nactions++] = (struct action) {
				.flag = option,
				.arg = optarg
			};
			break;

		case 'm':
		case 'U':
#ifdef HAS_REGEX_H
			actions[nactions].flag = option;
			compile_regex(&actions[nactions++].re, option, optarg);
			break;
#else
			die("-%c: regex is not compiled into this version of clenv", optarg);
#endif

		default:
			exit(EXIT_FAILURE);
		}
	}

	*argc -= optind;
	*argv += optind;

	// Setup the initial environment based on the flags that were passed.
	setup_initial_env(starting_env);

	for (int i = 0; i < nactions; ++i) {
		switch (actions[i].flag) {
		case 'v': clenv_set(actions[i].arg, actions[i].value); break;
		case 'u': clenv_unset(actions[i].arg); break;
#ifdef HAS_REGEX_H
		case 'm': clenv_set_matching(&actions[i].re); break;
		case 'U': clenv_unset_matching(&actions[i].re); break;
#endif
		default: die("bug!");
		}
	}
	free(actions);
}

int main(int argc, char *argv[]) {
	program_name = argv[0];
	inherited_environ = environ;

	parse_arguments(&argc, &argv);

	if (!argc)
		print_environment();
	else
		execute_program(argc, argv);
}
