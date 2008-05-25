
module Sprout
  
  class SWFFile
    COMPRESSED = 'CWS'
    
    def initialize(file)
      parse file
      yield self if block_given?
    end
    
    def version
      return @version ||= nil
    end
    
    def compressed?
      return @compressed ||= false
    end
    
    def debug?
      return @debug ||= false
    end
    
    protected
    
    def parse(file)
      puts "inside parse! with #{file}"
      
      File.open(file, 'r') do |f|
        @bytes = f.read
        parse_header
      end
    end
    
    def parse_header
      parse_compressed
      parse_version
      parse_file_size
      parse_frame_size
      parse_frame_rate
      parse_frame_count
#      @bytes.each_byte do |byte|
#        puts "byte: #{byte}"
#        break
#      end
    end
    
    def parse_compressed
      @compressed = (@bytes.slice!(0...3) == COMPRESSED)
    end
    
    def parse_version
      @version = @bytes.slice!(0).to_i
    end
    
    def parse_file_size
      parts = @bytes.unpack("")
      @size = parts.shift
      r1 = parts.shift
      r2 = parts.shift
      r3 = parts.shift
      r4 = parts.shift
      r5 = parts.shift
      puts "size: #{@size}"
      puts "r1: #{r1}"
      puts "r2: #{r2}"
      puts "r3: #{r3}"
      puts "r4: #{r4}"
      puts "r5: #{r5}"
    end
    
    def parse_frame_size
    end
    
    def parse_frame_rate
    end
    
    def parse_frame_count
    end

  end
end
