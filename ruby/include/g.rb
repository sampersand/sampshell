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

## The list of all global variables that `g` parsed out
GLOBALS = []

## A singleton method on `GLOBALS` used to validate that all variables that
# were parsed were expected. Note that because of how `g` works, there's no way
# to differentiate between `-x` and `--x`, but I've never had that be a problem.
def GLOBALS.expect!(*allowed)
  # Delete all leading `-`s that were possibly provided
  allowed = Array(*allowed).map { _1.sub!(/\A-*/, '') }

  # Find the first disallowed flag, and fail if it exists
  bad = (self - allowed).first and abort "flag #{bad} is not a recognized flag"

  # Hunky dory!
end

## Set a global variable to a value. This not only assigns to the actual global
# variable, but also adds it to the `GLOBALS` array, if it's not already there.
def GLOBALS.assign(flag, value, orig)
  flag.tr!('-', '_')

  # Only allow alphanumerics as flags
  unless flag.match? /\A\p{Alnum}+\z/
    abort "flag #{orig} is not a valid flag name"
  end

  # Special case booleans, nil, and integers:
  value = case value
          when 'true'    then true
          when 'false'   then false
          when 'nil'     then nil
          when /\A\d+\z/ then Integer value
          else                value
          end

  # Add the global variable to `self`
  (self << flag).uniq!

  # Assign the global variable. Sadly, there's no `global_variable_set`, so we
  # must use `eval`
  eval "\$#{flag} = value"
end

# Handle each argument, extracting the flag, or putting it back and `break`ing if we're done
while (arg = ARGV.shift)
  case arg
  # Negated flags: `--no-foo` is the same as `--foo=false`
  when /\A--no-([^=]+)\z/
    GLOBALS.assign($1, false, arg)

  # Special case: `--` on its own is an early break
  when '--'
    break

  # long-form flags, both with and without arguments
  when /\A--([^=]+)\K(=)?/
    GLOBALS.assign($1, $2 ? $' : true, $`)

  # Shorthand flags
  when /\A-[^-]/
    arg = arg.delete_prefix '-'

    while (short = arg.slice! 0)
      # Shorthand flag is given an argument with `=`
      if arg.delete_prefix!('=')
        GLOBALS.assign(short, arg, "-#{short}")
        break
      end

      # Shorthand flag is given an integer argument; `=` can be omitted
      if arg.start_with?(/\d/)
        unless (arg = Integer(arg, exception: false))
          abort("integer argument for -#{short} has trailing chars: #{arg}")
        end

        GLOBALS.assign(short, arg, "-#{short}")
        break
      end

      # Everything else is a single-character short string
      GLOBALS.assign(short, true, "-#{short}")
    end

  # Everything else is a normal argument, and we stop parsing
  else
    ARGV.unshift arg
    break
  end
end
