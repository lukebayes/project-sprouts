
module Sprout

  class OutputBuffer < String

    def initialize *args
      super
      @characters = ''
    end

    def puts msg
      @characters << msg
    end

    def print msg
      @characters << msg
    end

    def printf msg
      @characters << msg
    end

    def read
      response = @characters
      @characters = ''
      response
    end

    def flush
    end

  end
end

