## Script Utilities
#
# This file contains modifications to Ruby builtins that I find incredibly useful when writing
# scripts.
#
# While this file does alter builtins, it's purely backwards-compatible (barring the process title
# setting we do), and as such it can be used even in external scripts.
##

####################################################################################################
#                                      Set the Process Title                                       #
####################################################################################################

# Have a global variable that's just the filename, not its path. (This is useful in error messages,
# usages, and in `ps` outputs as it's much smaller)
$program_name = File.basename Process.argv0

# Change the process title to be `<program name> <arguments>`. Note that `setproctitle` will never
# raise an exception, even if it's unable to set it.
Process.setproctitle "#$program_name #{$*.join ' '}"

####################################################################################################
#                             Add Process Title to abort() and warn()                              #
####################################################################################################

## This add the program name to the beginning of `abort` and `warn`, to be more inline with other
# UNIX utilities.

def abort(message=$!)
  super("#$program_name: #{message}")
end

# This is actually slightly different from the builtin `warn`, as we allow `message` to be anything
# that has a `.to_s` defined on it---including exceptions!
def warn(message, ...)
  super("#$program_name: #{message}", ...)
end

####################################################################################################
#                              Add optional String message to exit()                               #
####################################################################################################

## Modify `Kernel.exit` to also accept a message before quitting. Quite useful!
#
# The message can either be supplied as the sole argument (in which case the default exit code is
# used), or as the second argument, with the exit code as the first.
#
def exit(code=true, message=nil)
  if code.is_a?(String)
    raise ArgumentError, 'both code and message given' if message
    message = code
    code = true
  end

  puts message if message

  super(code)
end

####################################################################################################
#                        Change Kernel.` to conditionally raise exceptions                         #
####################################################################################################

## It's irritating that ``Kernel.` `` doesn't actually raise exceptions, and you have to constantly
# check the value of `$?.success?`. This changes `` ` `` to now raise exceptions if the command
# starts with a `|` character (after deleting the `|`).
#
# As a useful utility, it _also_ prints out the command that's being run if `$VERBOSE` is enabled.
#
# This _should_ be a non-breaking-change, as `|` is not valid at the start of a line in `sh`.
def `(command)
  if command.start_with?('|')
    command = command.delete_prefix '|'
    exception = true
  end

  $stderr.puts "##$program_name: running: #{command}" if $VERBOSE
  result = super(command)

  if exception && !$?.success?
    # Same exception that `Kernel.system` raises
    raise RuntimeError, "command returned #{$?.exitstatus}: #{command}", caller(1)
  end

  result
end
