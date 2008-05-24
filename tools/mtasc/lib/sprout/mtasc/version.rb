module Sprout
  class MTASC #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 13
      TINY  = 7

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
