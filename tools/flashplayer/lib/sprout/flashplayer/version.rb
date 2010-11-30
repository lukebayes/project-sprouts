module Sprout
  class FlashPlayer # :nodoc:
    module VERSION #:nodoc:
      MAJOR = 10
      MINOR = 102
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
