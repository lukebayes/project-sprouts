
module Sprout

  # accepts a destination path and a sprout specification
  # and will download and unpack the platform-specific
  # archives that are identified in the spec
  class Builder # :nodoc:
    
    class BuilderError < StandardError #:nodoc:
    end

    def self.build(file_targets_yaml, destination)
      data = nil
      
      File.open(file_targets_yaml, 'r') do |f|
        data = f.read
      end
      
      platform = User.new.platform.to_s
      
      targets = YAML.load(data)
      targets.each do |target|
        # iterate over the provided RemoteFileTargets until we 
        # encounter one that is appropriate for our platform,
        # or one that claims to be universal.
        # When authoring a sprout.spec for libraries or tools,
        # put the most specific RemoteFileTargets first, then
        # universals to catch unexpected platforms.
        if(target.platform == 'universal' || target.platform == platform)
          target.install_path = FileUtils.mkdir_p(destination)
          target.resolve
          return target
        end
      end
      raise BuilderError.new("Sprout::Builder.build failed, unsupported platform or unexpected yaml")
    end
    
  end
end

