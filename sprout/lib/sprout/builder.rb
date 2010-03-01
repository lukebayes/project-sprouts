
module Sprout

  class BuilderError < StandardError #:nodoc:
  end

  # accepts a destination path and a sprout specification
  # and will download and unpack the platform-specific
  # archives that are identified in the spec
  class Builder # :nodoc:
    
    def self.build(file_targets_yaml, gem_name=nil, gem_version=nil)
      destination = Builder.gem_file_cache(gem_name, gem_version)
      data = nil
      
      File.open(file_targets_yaml, 'r') do |f|
        data = f.read
      end
      
      targets = YAML.load(data)
      targets.each do |target|
        # iterate over the provided RemoteFileTargets until we 
        # encounter one that is appropriate for our platform,
        # or one that claims to be universal.
        # When authoring a sprout.spec for libraries or tools,
        # put the most specific RemoteFileTargets first, then
        # universals to catch unexpected platforms.
        target.gem_name = gem_name
        target.gem_version = gem_version
        if(target.platform == platform || target.platform == 'universal')
          target.install_path = FileUtils.mkdir_p(destination)
          target.resolve
          return target
        end
      end
      raise BuilderError.new("Sprout::Builder.build failed, unsupported platform [#{platform}] or unexpected yaml")
    end
    
    private

    def self.gem_file_cache(gem_name, gem_version)
      Sprout.gem_file_cache(gem_name, gem_version)
    end
    
    def self.platform
      @@platform ||= User.new.platform.to_s
    end
    
  end
end

