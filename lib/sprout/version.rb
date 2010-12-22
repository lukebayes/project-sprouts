
module Sprout
  NAME = 'sprout'

  if(!defined? Sprout::VERSION)
    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 0
      TINY  = 34
      RELEASE = 'pre'

      STRING = [MAJOR, MINOR, TINY, RELEASE].join('.')
      MAJOR_MINOR = [MAJOR, MINOR].join('.')
    end
  end
end

