module Sprout
  class Flex3SDK #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 3
      MINOR = 3
      TINY  = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
