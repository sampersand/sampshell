# Ruby file containing modifications to builtins that I find useful when writing scripts

$program_name = File.basename $0, '.*'
trace_var :$0 do $program_name = File.basename($0, '.*') end
trace_var :$PROGRAM_NAME do $PROGRAM_BASE_NAME = File.basename($0, '.*') end

# Prefix program name to `abort` and `warn`
def abort(message=$!)
  super("#{$program_name}: #{message}")
end

def warn(message, ...)
  super("#{$program_name}: #{message}", ...)
end

# Have backticks raise exceptions by default, unless `$BACKTICK_NO_FAIL` is set

$backtick_fail = true
def shell(command, exception: $backtick_fail)
  puts "#running: #{command}" if $VERBOSE
  result = Kernel.`(command) #`

  if exception && !$?.success?
    raise RuntimeError, "command returned #{$?.exitstatus}: #{command}", caller(1)
  end

  result
end
alias ` shell
