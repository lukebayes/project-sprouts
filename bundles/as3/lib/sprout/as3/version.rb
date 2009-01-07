module Sprout # :nodoc:
  class AS3 # :nodoc:
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 0
      TINY  = 12

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
