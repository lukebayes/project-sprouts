
module Sprout

  class OutputBuffer < Logger
    
    def initialize *args
      super
      @characters = ''
    end

    def puts msg
      flush if @characters.size > 0
      info msg
    end

    def print msg
      @characters << msg
      flush
    end

    def printf msg
      @characters << msg
      flush
    end
    
    def flush
      if @characters.match /\n/
        info @characters
        @characters = ''
      end
    end

  end
end

