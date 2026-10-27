#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <regex.h>
#include <assert.h>

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

// Utility function to print an error message to stderr and exit.
#define die(...) do { \
		fprintf(stderr, "%s: ", program_name); \
		fprintf(stderr, __VA_ARGS__); \
		fputc('\n', stderr); \
		fflush(stderr); \
		exit(EXIT_FAILURE); } while (0)

#define log(level, ...) do { \
		if (verbose > (level)) { \
			fputs("#clenv ", stderr); \
			fprintf(stderr, __VA_ARGS__); \
			fputc('\n', stderr); \
		} } while(0)
/******************************************************************************
 *                                                                            *
 *                       Interact with the Environment                        *
 *                                                                            *
 ******************************************************************************/

/**
 * Sets the value of `name` to `value` in the environment. The name must be
 * valid (nonnull, nonempty, and cannot have `=`), and the value must be
 * nonnull.
 */
void clenv_set(const char *name, const char *value) {
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`
	assert(value);

	log(0, "setting:   %s=%s", name, value);

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
 */
void clenv_unset(const char *name) {
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`

	log(0, "unsetting: %s", name);

	if (unsetenv(name) == -1) {
		// Note we use `perror` since the error case is very unlikely
		// (memory exhaustion; we already validate the name normally)
		perror(program_name);
		abort();
	}
}

/**
 * Fetches the original value of `name` that was inherited from the environment.
 * Returns `NULL` if the name wasn't present. The name must be valid (nonnull,
 * nonempty, and cannot have `=`).
 */
char *lookup_inherited_value(const char *name) {
	assert(name);               // non-null
	assert(*name);              // non-empty
	assert(!strchr(name, '=')); // does not have `=`

	char *value, **tmp_environ;

	tmp_environ = environ;
	environ = inherited_environ;

	// We check `errno` here since a return value of `NULL` could also just mean
	// it wasn't found inthe environment.
	errno = 0;
	if (!(value = getenv(name)) && errno) {
		// Note we use `perror` since the error case is impossible (we already
		// validate the name)
		perror(program_name);
		abort();
	}
	environ = tmp_environ;

	return value;
}

/**
 * Finds all parameters in the inherited environment whose names match
 * `pattern`, and sets them in the current environment.
 */
void clenv_set_matching(const char *pattern) {
	regex_t re;
	int err = regcomp(&re, pattern, REG_EXTENDED);
	if (err) {
		char buf[4096];
		regerror(err, &re, buf, sizeof(buf));
		die("-m: bad regex '%s': %s", pattern, buf);
	}

	for (int i = 0; inherited_environ[i]; ++i) {
		char *eql = strchr(inherited_environ[i], '=');
		if (!eql) die("[bug] no `=` found in environ of %s", environ[i]);

		char *name = strndup(inherited_environ[i], eql - inherited_environ[i]);
		if (!regexec(&re, name, 0, 0, 0)) {
			clenv_set(name, eql + 1);
		} else {
			log(1, "  -m: doesnt match '%s': %s", pattern, name);
		}

		free(name);
	}

	regfree(&re);
}

/**
 * Unsets all parameters in the environment whose names match `pattern`.
 */
void clenv_unset_matching(const char *pattern) {
	regex_t re;
	int err = regcomp(&re, pattern, REG_EXTENDED);
	if (err) {
		char buf[4096];
		regerror(err, &re, buf, sizeof(buf));
		die("-U: bad regex '%s': %s", pattern, buf);
	}

	int nmatches = 0, cap = 4;
	char **matches = malloc(sizeof(char *) * cap); // todo: optimize when nothing matches?

	for (int i = 0; environ[i]; ++i) {
		char *eql = strchr(environ[i], '=');
		if (!eql) die("[bug] no `=` found in environ of %s", environ[i]);

		char *name = strndup(environ[i], eql - environ[i]);
		if (!regexec(&re, name, 0, 0, 0)) {
			if (nmatches == cap)
				matches = realloc(matches, sizeof(char *) * (cap *= 2));
			matches[nmatches++] = name;
		} else {
			log(1, "  -U: doesnt match '%s': %s", pattern, name);
			free(name);
		}
	}

	regfree(&re);
	for (int i = 0; i < nmatches; ++i)
		clenv_unset(matches[i]), free(matches[i]);
	free(matches);
}

/******************************************************************************
 *                               Business Logic                               *
 ******************************************************************************/

enum starting_env { MINIMAL_ENV, EMPTY_ENV, INHERIT_ENV };

void setup_initial_env(enum starting_env starting_env) {
	// If we inherit the environment, don't do anything special.
	if (starting_env == INHERIT_ENV) {
		log(1, "inheriting environment");
		return;
	}

	// Otherwise, clear the environment by setting a new one.
	environ = malloc(1);
	log(0, "clearing environment");

	// If we're not setting up the minimal env, we're done.
	if (starting_env != MINIMAL_ENV)
		return;

	log(1, "setting up minimal environment");

	// Now take all the "minimal" environment values and forward them through.
	const char *minimal_env[] = {"TERM", "HOME", "SHLVL", "LANG"};

	char *value;
	for (unsigned long i = 0; i < sizeof(minimal_env) / sizeof(char *); i++) {
		if ((value = lookup_inherited_value(minimal_env[i])))
			clenv_set(minimal_env[i], value);
	}
}

void usage(void) {
	printf("usage: %s [options] [utility ...arguments]\n", program_name);
	puts("options:");
    puts("\t-h              Print this");
    puts("\t-D              Don't actually run the program; Sets -V");
    puts("\t-V              Print the invocation, and any changed variables.");
    puts("\t-P ALTPATH      Use 'ALTPATH' to find 'utility', instead of $PATH");
    puts("\t-p              Shorthand for -vPATH -P$PATH");
    puts("\t-a              Pass all environment variables in by default");
    puts("\t-n, -i          Don't set any arguments by default, including \"minimal ones\"");
    puts("\t-v NAME[=VALUE] Puts 'NAME' in the environment of 'utility'. If 'VALUE' is");
    puts("\t                omitted, it uses the current VALUE (or errors if unset).");
    puts("\t-u NAME         Unset 'NAME'. Ignores unset names.");
    puts("\t-m PATTERN      Sets variables that match PATTERN");
    puts("\t-U PATTERN      Unsets variables which match the regex.");

	exit(0);
}

// not a const char, as we modify it. Caller must dup if if they want to not modify it.
char *find_executable_path(const char *exe) {
	log(1, "Searching for %s in %s", exe, alt_path);

	char *alt_path2 = strdup(alt_path);

	for (char *entry = strtok(alt_path2, ":"); entry; entry = strtok(NULL, ":")) {
		long size = strlen(entry) + 1 + strlen(exe) + 1;
		char *path = malloc(size);
		snprintf(path, size, "%s/%s", entry, exe);

		if (!access(path, X_OK)) {
			log(1, "  matched: %s", path);
			free(alt_path2);
			return path;
		} else {
			log(2, "  didnt match: %s", path);
		}
		free(path);
	}

	return free(alt_path2), NULL;
}

/**
 * Prints the environment to stdout, one name per line.
 */
void print_environment(void) {
	if (alt_path)
		die("cannot supply an alternative $PATH and no executable");

	for (int i = 0; environ[i]; ++i)
		puts(environ[i]);
}

/**
 * Executes the program in `argv[0]`, potentially resolving its path first (via
 * a `find_executable_path` lookup). Does nothing if `dry_mode` is set.
 */
void execute_program(int argc, char *argv[]) {
	if (verbose) {
		log(0, "executing: %s", argv[0]);

		for (int i = 0; i < argc; ++i)
			log(0, "  argv[%d]= '%s'", i, argv[i]);
	}

	// Don't actually run the command in dry mode.
	if (dry_mode) return;

	errno = 0;
	if (alt_path) {
		char *orig = argv[0];
		if (!(argv[0] = find_executable_path(orig)))
			die("%s: No such file or directory", orig);
		execv(argv[0], argv);
	} else {
		execvp(argv[0], argv);
	}

	die("exec of %s failed: %s", argv[0], strerror(errno));
}

/**
 * Parses command line flags out from `argv`, and populates any relevant global
 * variables. Updates `argc` and `argv` to point to the remaining non-flag
 * arguments (if any).
 */
void parse_arguments(int *argc, char ***argv) {
	const char *options = "+hDVaniv:u:m:U:pP:";

	// Scan the argument list for options which should be processed before
	// any others. (This makes setting up a new environment significantly
	// easier.)
	enum starting_env starting_env = MINIMAL_ENV;
	int ch;
	opterr = 0;
	while ((ch = getopt(*argc, *argv, options)) != -1) {
		switch (ch) {
		// Set the initial environment: inherited, empty, or minimal (default)
		case 'a':
			starting_env = INHERIT_ENV;
			break;
		case 'n':
		case 'i':
			starting_env = EMPTY_ENV;
			break;

		// Check for dry and verbose; verbose is checked in initial env setup.
		case 'D':
			dry_mode = 1;
			// fallthrough
		case 'V':
			verbose++; // Repeat multiple times for more specificity
			break;

		// Might as well check for usage early on too.
		case 'h':
			usage();

		default:
			; // Intentionally nothing, as we'll parse the other options later.
		}
	}

	// Setup the initial environment based on the flags that were passed.
	setup_initial_env(starting_env);

	// Now, go through and parse out all the remaining options that didn't need
	// to be handled out-of-order.
	optind = 1;
	opterr = 1;
	while ((ch = getopt(*argc, *argv, options)) != -1) {
		switch (ch) {
		case 'a':
		case 'n':
		case 'i':
		case 'h':
		case 'V':
		case 'D':
			break; // already handled

		case 'P':
			alt_path = optarg;
			break;

		case 'p':
			alt_path = lookup_inherited_value("PATH");
			if (!alt_path)
				die("-p: $PATH is not set.");

			clenv_set("PATH", alt_path);
			break;

		case 'v':
			if (!*optarg)
				die("-u: argument must not be empty");

			char *value;

			// Parse out `-v NAME=VALUE` vs just `-v NAME`.
			if ((value = strchr(optarg, '='))) {
				*value++ = '\0';
			} else if (!(value = lookup_inherited_value(optarg))) {
				die("-v %s: variable is unset", optarg);
			}
			clenv_set(optarg, value);
			break;

		case 'u':
			if (!*optarg)
				die("-u: argument must not be empty");

			if (strchr(optarg, '='))
				die("-u: variable name cannot contain an '=': %s", optarg);

			clenv_unset(optarg);
			break;

		case 'm':
			clenv_set_matching(optarg);
			break;

		case 'U':
			clenv_unset_matching(optarg);
			break;

		default:
			exit(EXIT_FAILURE);
		}
	}

	*argc -= optind;
	*argv += optind;
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
