# Ruby file containing modifications to builtins that I find useful when writing scripts

return if defined?($SAMPSCRIPT_DISABLED)

PROGRAM_BASE_NAME = File.basename($0, '.*')

## Always import shell words, and make it easy to use.
require 'shellwords'
class String
  alias ~@ shellescape
  alias escape shellescape
end

# Prefix program name to `abort` and `warn`; support `warn()` too
def abort(message=$!) = super("#{PROGRAM_BASE_NAME}: #{message}")
def warn(message=$!) = super("#{PROGRAM_BASE_NAME}: #{message}")

# Add a `debug()` method for logging
def debug(message=nil)
  puts("#{PROGRAM_BASE_NAME}: #{message || yield}") if $VERBOSE
end

# Define `failure?` as not success.
class Process::Status
  def failure? = !success?
  alias code exitstatus
  alias status exitstatus
end

# Refine the `` ` `` builtin to fail when `$ERR_FAIL` isn't set
$ERR_FAIL = true unless defined? $ERR_FAIL
alias $-e $ERR_FAIL # lol, `$-e = true`, like shells

def `(command)
  debug command
  result = super.chomp
  if $ERR_FAIL && $?.failure?
    raise RuntimeError, "command returned #{$?.exitstatus}: #{command}", caller(1)
  end
  result
end
