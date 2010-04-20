
module Sprout

  class FileTarget

    attr_accessor :archive_type
    attr_accessor :libraries
    attr_accessor :md5
    attr_accessor :platform
    attr_accessor :url

    def initialize platform
      @platform = platform
      @libraries = []
      @executables = []
    end

    def add_library type, location
      @libraries << {:type => type, :location => location}
    end

    def add_executable name, location
      @executables << {:name => name, :location => location}
    end
  end
end

