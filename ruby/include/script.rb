# Ruby file containing modifications to builtins that I find useful when writing scripts

$PROGRAM_BASE_NAME = File.basename($0, '.*')
trace_var :$0 do
  $PROGRAM_BASE_NAME = File.basename($0, '.*')
end
trace_var :$PROGRAM_NAME do
  $PROGRAM_BASE_NAME = File.basename($0, '.*')
end

# Prefix program name to `abort` and `warn`
def abort(message=$!)
  super("#$PROGRAM_BASE_NAME: #{message}")
end
def warn(message, ...)
  super("#$PROGRAM_BASE_NAME: #{message}", ...)
end

# Have `foo` raise exceptions

$ERR_FAIL = true
def `(command)
  puts command if $-v
  result = super.chomp
  if $ERR_FAIL && !$?.success?
    raise RuntimeError, "command returned #{$?.exitstatus}: #{command}", caller(1)
  end
  result
end
