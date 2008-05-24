module Sprout
  class Flex4SDK #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 4
      MINOR = 0
      TINY  = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
