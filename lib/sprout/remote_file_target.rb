
module Sprout

  class RemoteFileTarget < FileTarget

    attr_accessor :archive_type
    attr_accessor :url
    attr_accessor :md5

    def add_resource name, target
      puts "add resource: #{name} target: #{target}"
    end
  end
end

