#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <regex.h>
#include <assert.h>

#define LOG (fprintf(stderr, "%s:%s:%d\n", __FILE__, __FUNCTION__, __LINE__), fflush(stderr))
#define die(...) do { \
		fprintf(stderr, "%s: ", program_name); \
		fprintf(stderr, __VA_ARGS__); \
		fputc('\n', stderr); \
		fflush(stderr); \
		exit(EXIT_FAILURE); } while (0)
extern char **environ;
char **inherited_environ;
const char *program_name;

int dry_mode, verbose;
const char *alt_path;

enum starting_env { MINIMAL_ENV, EMPTY_ENV, INHERIT_ENV };

/******************************************************************************
 *                                                                            *
 *                       Interact with the Environment                        *
 *                                                                            *
 ******************************************************************************/

void clenv_set(const char *restrict name, const char *restrict value) {
	assert(name);
	assert(value);

	if (setenv(name, value, 1) == -1)
		die("unable to set %s: %s", name, strerror(errno));

	if (verbose)
		printf("#clenv setting:   %s=%s\n", name, value);
}

void clenv_unset(const char *restrict name) {
	assert(name);

	if (unsetenv(name) == -1)
		die("unable to unset %s: %s", name, strerror(errno));

	if (verbose)
		printf("#clenv unsetting: %s\n", name);
}

char *lookup_inherited_value(const char *name) {
	char *value, **tmp_environ;

	tmp_environ = environ;
	environ = inherited_environ;
	errno = 0;
	value = getenv(name);
	if (errno) die("error!");
	environ = tmp_environ;

	return value;
}

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
	for (int i = 0; i < sizeof(minimal_env) / sizeof(char *); i++) {
		if ((value = lookup_inherited_value(minimal_env[i]))) {
			clenv_set(minimal_env[i], value);
		}
	}
}

void print_environ(void) {
	for (int i = 0; environ[i]; ++i)
		puts(environ[i]);
}

void set_matching(const char *pat) {
	regex_t re;
	int err = regcomp(&re, pat, REG_EXTENDED | REG_EXTENDED);
	if (err) die("bad regex: %s", pat); // TODO `regerror`
	for (int i = 0; inherited_environ[i]; ++i) {
		char *s = strchr(inherited_environ[i], '=');
		if (!s) die("no `=` found in environ?");
		char *name = strndup(inherited_environ[i], s - inherited_environ[i]);
		int does_match = regexec(&re, name, 0, 0 ,0);
		if (does_match != REG_NOMATCH)
			clenv_set(name, s + 1);
		free(name);
	}
	regfree(&re);
}

void unset_matching(const char *pat) {
	regex_t re;
	int err = regcomp(&re, pat, REG_EXTENDED | REG_EXTENDED);
	if (err) die("bad regex: %s", pat); // TODO `regerror`

	int nmatches = 0, cap = 4;
	char **matches = malloc(sizeof(char *) * cap); // todo: optimize when nothing matches?

	for (int i = 0; environ[i]; ++i) {
		char *s = strchr(environ[i], '=');
		if (!s) die("no `=` found in environ?");

		char *name = strndup(environ[i], s - environ[i]);
		int does_match = regexec(&re, name, 0, 0 ,0);
		if (does_match == REG_NOMATCH) {
			free(name);
		} else {
			if (nmatches == cap) {
				matches = realloc(matches, sizeof(char *) * (cap *= 2));
			}
			matches[nmatches++] = name;
		}
	}
	regfree(&re);
	for (int i = 0; i < nmatches; ++i) {
		clenv_unset(matches[i]);
		free(matches[i]);
	}
	free(matches);
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

const char *options = "hDVaniv:u:m:U:pP:";
int main(int argc, char *const argv[]) {
	program_name = argv[0];

	// Find starting clenv starting_env
	enum starting_env starting_env = MINIMAL_ENV;
	inherited_environ = environ;

	opterr = 0;
	int ch;
	while ((ch = getopt(argc, argv, options)) != -1) {
		switch (ch) {
		case 'h':
			usage();
		case 'a': starting_env = INHERIT_ENV; break ;;
		case 'n': case 'i': starting_env = EMPTY_ENV; break ;;
		case 'D': dry_mode = 1; // fallthrough
		case 'V': verbose++; break;
		}
	}

	setup_initial_env(starting_env);

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
			if (!alt_path) die("$PATH is not set in calling environment?");
			clenv_set("PATH", alt_path);
			break;

		case 'v':;
			// If a value was assigned, then use that
			if (strchr(optarg, '=')) {
				// TODO: dont use putenv
				putenv(optarg);
				if (errno) die("error!");
			} else {
				char *value = lookup_inherited_value(optarg);
				if (!value) {
					die("environment variable %s is unset", optarg);
				}
				clenv_set(optarg, value);
			}
			break;

		case 'u':
			clenv_unset(optarg);
			break;

		case 'm':
			set_matching(optarg);
			break;

		case 'U':
			unset_matching(optarg);
			break;

		default:
			die("todo");
		}
	}

	// We're done parsing options, advance `argv` / `argc` to past the options
	argv += optind;
	argc -= optind;

	// If no program was specified, just print the environment out.
	if (argc <= 0) { // TODO: can it ever get bigger than this?
		print_environ();
		exit(EXIT_SUCCESS);
	}

	// Otherwise, let's execute it
	if (verbose) {
		printf("#clenv executing: %s\n", argv[0]);
		for (int i = 0; i < argc; ++i)
			printf("#clenv    argv[%d]='%s'\n", i, argv[i]);
	}

	errno = 0;
	if (alt_path) {
		// TODO: is `execvP` posix? if not, we have to find this ourself.
		execvP(argv[0], alt_path, argv);
	} else {
		execvp(argv[0], argv);
	}
	die("exec of %s failed: %s", argv[0], strerror(errno));
}
