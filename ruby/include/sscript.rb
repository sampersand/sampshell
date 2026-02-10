## Script Utilities
#
# This file contains modifications to Ruby builtins that I find incredibly useful when writing
# scripts.
#
##

def ENV.get_nonempty(key)
  value = self[key]
  value.nil? || value.empty? ? nil : value
end

def ENV.fetch_nonempty(key, default = nodefault=true)
  if !nodefault && defined?(yield)
    warn "warning: block supersedes default value argument"
  end

  value = self[key]
  return value unless value.nil? || value.empty?

  case
  when defined?(yield) then yield key
  when !nodefault then default
  else raise KeyError, "key #{value.nil? ? 'not found' : 'empty'}: #{key}"
  end
end
