
module Sprout

  class RemoteFileTarget < FileTarget

    attr_accessor :archive_type
    attr_accessor :url
    attr_accessor :md5

    attr_reader :executables

    def initialize
      @executables = []
      super
   end

    def add_executable name, target
      executables << { :name => name, :target => target }
    end
  end
end

