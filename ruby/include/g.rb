#!ruby

## `g.rb`: An option parser that's more sophisticated than `-s`
#
# Inspired by my feature request (https://bugs.ruby-lang.org/issues/21015),
# this implements what I wish the `-g` flag in Ruby would be: A fast-and-dirty
# way to specify command-line-arguments that just populate a corresponding
# global variable.
##

## Emulate other `$-x` globals, so you can check for `g`'s inclusion with `$-g`.
$-g = true

## Users can supply the `G_VARS` environment variable to `g` to specify the list
# of allowed global variables; if a variable is not in this list, it'll cause a
# program abort.
g_vars = ENV['G_VARS']&.split(',') # Not a constant so it doesn't leak

## Set a global variable to a value. Not a method, like `g_vars`, so it doens't
# leak out of this file.
set_global = proc do |flag, value, orig_flag|
  flag.tr!('-', '_')

  # Only allow alphanumerics as flags
  unless flag.match? /\A\w+\z/
    abort "flag #{orig_flag} is not a valid flag name"
  end

  # If `G_VARS` was supplied as an env var, then ensure the flag is allowed
  if g_vars && !g_vars.include?(flag)
    abort "flag #{orig_flag} is not a recognized flag"
  end

  # Special case booleans, nil, and integers:
  value = case value
          when 'true'         then true
          when 'false'        then false
          when 'nil'          then nil
          when /\A\d+\z/      then Integer value
          # when %r{\A/(.*)/\z} then Regexp $1
          else                     value
          end

  # Sadly, there's no `global_variable_set`, so we must use `eval`
  eval "\$#{flag} = value"
end

# Handle each argument, extracting the flag, or putting it back and `break`ing if we're done
while (arg = ARGV.shift)
  case arg
  when /\A--no-([\w-]+)\z/
    # Negated flags: `--no-foo` is the same as `--foo=false`
    set_global.($1, false)

  when /\A--([\w-]+)(?:=(.*))?\z/
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
