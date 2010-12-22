
module Sprout
  NAME = 'sprout'
  module VERSION #:nodoc:
    STRING      = File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION').strip)
    MAJOR       = STRING.split('.')[0]
    MINOR       = STRING.split('.')[1]
    TINY        = STRING.split('.')[2]
    RELEASE     = STRING.split('.')[3]
    MAJOR_MINOR = [MAJOR, MINOR].join('.')
  end
end

