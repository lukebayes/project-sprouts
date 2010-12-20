
module Sprout #:nodoc:
  
  class Log #:nodoc:
    @@debug = false
    @@output = ''
    @@printout = ''
    
    def Log.debug=(debug)
      @@debug = debug
    end
    
    def Log.debug
      return @@debug
    end
    
    def Log.puts(msg)
      @@output << msg + "\n"
      Log.flush
    end
    
    def Log.print(msg)
      @@printout << msg
      Log.flush_print
    end
    
    def Log.printf(msg)
      @@printout << msg
      Log.flush_print
    end
    
    def Log.flush_print
      if(!Log.debug)
        $stdout.printf @@printout
        @@printout = ''
      end
    end
    
    def Log.flush
      if(!Log.debug)
        $stdout.printf @@output
        @@output = ''
      end
    end
  end
end

