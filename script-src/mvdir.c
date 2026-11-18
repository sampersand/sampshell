#ifdef __linux__
# define _GNU_SOURCE
#endif
/**
 * Honestly, this script could just be `mv -T` in gnu move...
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#define LOG(...) (fprintf(stderr, "%s:%d", __FUNCTION__, __LINE__), fprintf(stderr, __VA_ARGS__), fputc('\n',stderr),fflush(stderr))
enum mode {
	NEVER_OVERWRITE = 'n',
	FORCE_OVERWRITE = 'f',
	INTERACTIVE_OVERWRITE = 'i'
};

static int rename_dir(
	const char *restrict old,
	const char *restrict new,
	enum mode mode);

#if defined(__APPLE__) && defined(__MACH__)
#include <fcntl.h>
static int
rename_dir(const char *restrict old, const char *restrict new, enum mode m)
{
	int result = renameatx_np(AT_FDCWD, old,
	                          AT_FDCWD, new,
	                          m == NEVER_OVERWRITE ? RENAME_EXCL : 0);
	if (result == 0)
		return 1; // success!

	// EEXIST
	if (result) {
		perror("mvdir");
		return 0;
		// exit(EXIT_FAILURE);
	}
		return 1;
}
#endif

int main(int argc, char **argv) {
	char *program_name = argv[0];
	int option;
	char mode = 'n';

	while ((option = getopt(argc, argv, "niv")) != -1) {
		switch (option) {
		case 'n':
		case 'i':
		case 'f': mode = option; break;
		default:
			exit(EXIT_FAILURE);
		}
	}

	argc -= optind;
	argv += optind;

	if (argc != 2) {
		printf("usage: %s [-niv] src dst", program_name);
	}

	if (!rename_dir(argv[0], argv[1], mode)) {
		printf("%s: cannot rename %s to %s: %s\n", program_name, argv[0], argv[1], strerror(errno));
		exit(EXIT_FAILURE);
	}
}
