#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <regex.h>

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

int dry_mode, verbose_mode;
const char *alt_path;

enum starting_env { MINIMAL_ENV, EMPTY_ENV, INHERIT_ENV };

const char *minimal_env[] = {"TERM", "HOME", "SHLVL", "LANG", 0};



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
	switch (starting_env) {
	case INHERIT_ENV:
		break;
	case EMPTY_ENV:
		environ = malloc(1);
		break;
	case MINIMAL_ENV:
		environ = malloc(1);
		char *value;
		for (int i = 0; minimal_env[i]; i++) {
			if ((value = lookup_inherited_value(minimal_env[i]))){
				setenv(minimal_env[i], value, 1);
				if (errno) die("error!");
			}
		}
	}

}

void print_environ(void) {
	for (int i = 0; environ[i]; ++i)
		puts(environ[i]);
}

void usage(void) {
	printf("<todo: usage>");
	exit(0);
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
		if (does_match != REG_NOMATCH) {
			if (setenv(name, s + 1, 1) == -1) die("error?");
		}
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
		if (unsetenv(matches[i]) == -1) die("error?");
		free(matches[i]);
	}
	free(matches);
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
			break; // already handled

		case 'D': dry_mode = 1; // fallthrough
		case 'V': verbose_mode = 1; break;

		case 'P':
			alt_path = optarg;
			break;

		case 'p':
			alt_path = lookup_inherited_value("PATH");
			if (!alt_path) die("$PATH is not set in calling environment?");
			setenv("PATH", alt_path, 1);
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
				setenv(optarg, value, 1);
				if (errno) die("error!");
			}
			break;

		case 'u':
			if (unsetenv(optarg) == -1) {
				die("invalid -u value: %s", optarg);
			}
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

	// If no program was specified, just print the environment out.
	if (argc == optind) { // TODO: can it ever get bigger than this?
		print_environ();
		exit(EXIT_SUCCESS);
	}

	// Otherwise, let's execute it
	// execvP()
	execvP(argv[optind], alt_path, &argv[optind]);
	die("exec failed: %s", strerror(errno));

	/*
	options:
    -h              Print this
    -P altpath      Use 'altpath' to find 'utility', instead of \$PATH
    -a              Pass all environment variables in by default
    -n, -i          Don't set any arguments by default, including "essential ones"
    -v name[=value] Puts 'name' in the environment of 'utility'. If 'value' is
                    omitted, it uses the current value (or errors if unset).
    -u name         Unset 'name'. If both -v and -u are given, -u wins.
    -m pattern      Pass in any variables matching the awk pattern.
    -U pattern      Unsets any variables which match the awk pattern.
    -p              Shorthand for -vPATH -P\$PATH
    -D              Don't actually run the program; Sets -V
    -V              Print the invocation, and any changed variables.
    */
	// printf("%s\n", environ);
}
