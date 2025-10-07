#!ruby

## `G.rb`: An option parser that's more sophisticated than `-s`
#
# Inspired by my feature request (https://bugs.ruby-lang.org/issues/21015),
# this implements what I wish the `-g`/`-G` flag in ruby would have

# Emulate other `$-x` globals, so you can check for `G.rb`'s existance via `$-G`
$-G = true

# The list of all global variables thatGG parsed out
$Globals = []
g_vars = ENV['G_VARS']&.split(',')

# Local variable so as to not leak
set_global = proc do |key, value|
  key.tr!('-', '_')

  if g_vars && !g_vars.include?(key)
    abort "invalid option: #{key}"
  end

  value = case value
          when 'true'         then true
          when 'false'        then false
          when 'nil'          then nil
          when /\A\d+\z/      then Integer value
          # when %r{\A/(.*)/\z} then Regexp $1
          else                     value
          end
  $Globals |= [key]
  eval "\$#{key} = value"
end

# Check for each argument
while (arg = ARGV.shift)
  case arg
  when /\A--no-([-\w]+)\z/
    # Negated flags: `--no-foo` is the same as `--foo=false`
    set_global.($1, false)

  when /\A--([-\w]+)(?:=(.*))?/
    # long-form flags, both with and without arguments
    set_global.($1, $2 || true)

  when /\A-[^-]/
    # Shorthand flags
    arg = arg.delete_prefix '-'

    while (short = arg.slice! 0)
      case
      when arg.delete_prefix!('=')
        # Shorthand flag is given an argument with `=`
        set_global.(short, arg)
        break
      when arg.match?(/\A\d/)
        # Shorthand flag is given an integer argument; `=` can be omitted
        arg = Integer(arg) rescue abort("integer argument for -#{short} has trailing chars: #{arg}")
        set_global.(short, arg)
        break
      else
        set_global.(short, true)
      end
    end
  else
    # Everything else is a normal argument, and we stop parsing
    ARGV.unshfit arg
    break
  end
end
