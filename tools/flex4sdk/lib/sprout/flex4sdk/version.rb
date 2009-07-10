module Sprout
  class Flex4SDK #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 4
      MINOR = 1
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
