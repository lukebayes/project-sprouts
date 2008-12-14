module Sprout
  class Flex3SDK #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 0
      TINY  = 3

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
