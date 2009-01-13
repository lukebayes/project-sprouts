module Sprout
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 7
    TINY  = 200

    STRING = [MAJOR, MINOR, TINY].join('.')
    MAJOR_MINOR = [MAJOR, MINOR].join('.')
  end
end
