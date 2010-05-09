
module Sprout
  if(!defined? Sprout::VERSION)
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 0
      TINY  = 'pre'

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end

