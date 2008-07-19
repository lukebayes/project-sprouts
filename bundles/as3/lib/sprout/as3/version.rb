module Sprout # :nodoc:
  class AS3 # :nodoc:
    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 2
      TINY  = 8

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
