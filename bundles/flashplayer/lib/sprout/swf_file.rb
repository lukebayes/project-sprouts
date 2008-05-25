
module Sprout

  class SWFFile
    
    def initialize(file)
      yield self if block_given?
    end
    
    def debug?
      return false
    end

  end
end
