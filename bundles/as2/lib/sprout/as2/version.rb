module Sprout
  class AS2 # :nodoc:
    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 1
      TINY  = 28

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
