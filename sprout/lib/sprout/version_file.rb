module Sprout
  
  # Used by the GitTask to load, parse and persist Version information
  # related to a project.
  # Expects a file with a 3 digit number, separated by periods like:
  #
  #   3.4.2
  #
  # Create with a path to the file like:
  # 
  #   version = VersionFile.new('path/Version.txt')
  #
  class VersionFile
    
    def initialize(file_path)
      @file_path = file_path
      read_value
    end
    
    def value=(value)
      @value = value
      write_value
    end
    
    def value
      @value
    end
    
    def major_version
      @value.split('.').shift.to_i
    end
    
    def minor_version
      @value.split('.')[1].to_i
    end
    
    def revision
      @value.split('.').pop.to_i
    end
    
    def increment_revision
      self.revision = self.revision + 1
    end
    
    def to_s
      @value
    end
    
    def to_str
      @value
    end
    
    def to_tag
      parts = value.split('.')
      parts[0] = add_leading_zeros(parts[0], 2)
      parts[1] = add_leading_zeros(parts[1], 2)
      parts[2] = add_leading_zeros(parts[2], 3)
      return parts.join('.')
    end
    
    private
    
    def add_leading_zeros(str, digits)
      (digits - str.size).times do
        str = "0#{str}"
      end
      str
    end
    
    def read_value
      File.open(@file_path, 'r') do |file|
        @value = file.read.strip
      end
    end
    
    def write_value
      File.open(@file_path, 'r+') do |file|
        file.write @value
      end
    end
    
    def revision=(revision)
      parts = @value.split('.')
      parts[2] = revision
      @value = parts.join('.')
      write_value
    end
  end
end
