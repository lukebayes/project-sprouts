module Sprout
  class Flex3SDK #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 5
      TINY  = 2

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
