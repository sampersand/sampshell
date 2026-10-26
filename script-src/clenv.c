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

	if (verbose)
		printf("#clenv setting:   %s=%s\n", name, value);

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

	if (verbose)
		printf("#clenv unsetting: %s\n", name);

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
		} else if (verbose > 1) {
			printf("#clenv   -m: doesnt match '%s': %s\n", pattern, name);
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
			if (verbose > 1) {
				printf("#clenv   -U: doesnt match '%s': %s\n", pattern, name);
			}
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
		if (verbose > 1) puts("#clenv inheriting environment");
		return;
	}

	// Otherwise, clear the environment by setting a new one.
	environ = malloc(1);
	if (verbose)
		puts("#clenv clearing environment");

	// If we're not setting up the minimal env, we're done.
	if (starting_env != MINIMAL_ENV)
		return;

	if (verbose) puts("#clenv setting up minimal environment");

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

const char *options = "+hDVaniv:u:m:U:pP:";
int main(int argc, char *const argv[]) {
	program_name = argv[0];
	inherited_environ = environ;

	// The alternative `$PATH` to use. Set by `-p` and `-P`.
	const char *alt_path = 0;

	// Scan the argument list for options which should be processed before
	// any others. (This makes setting up a new environment significantly
	// easier.)
	enum starting_env starting_env = MINIMAL_ENV;
	int ch;
	opterr = 0;
	while ((ch = getopt(argc, argv, options)) != -1) {
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
	while ((ch = getopt(argc, argv, options)) != -1) {
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
			return EXIT_FAILURE;
		}
	}

	// We're done parsing options, advance `argv` / `argc` to past the options
	argv += optind;
	argc -= optind;

	// If no program was specified, just print the environment out.
	if (argc <= 0) { // TODO: can it ever get bigger than this?
		for (int i = 0; environ[i]; ++i)
			puts(environ[i]);
		return EXIT_SUCCESS;
	}

	// Otherwise, let's execute it
	if (verbose) {
		printf("#clenv executing: %s\n", argv[0]);
		for (int i = 0; i < argc; ++i)
			printf("#clenv    argv[%d]='%s'\n", i, argv[i]);
	}

	// Don't actually run the command in dry mode.
	if (dry_mode)
		return EXIT_SUCCESS;

	errno = 0;
	if (alt_path) {
		// TODO: is `execvP` posix? if not, we have to find this ourselves.
		execvP(argv[0], alt_path, argv);
	} else {
		execvp(argv[0], argv);
	}

	die("exec of %s failed: %s", argv[0], strerror(errno));
}
