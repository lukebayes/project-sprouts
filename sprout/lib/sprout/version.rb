module Sprout
  if(!defined? Sprout::VERSION)
    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 7
      TINY  = 218

      STRING = [MAJOR, MINOR, TINY].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end
