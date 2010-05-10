
module Sprout::Tool

  class << self
    # When you create and distribute a Sprout Tool, you 
    # need to get a regular Ruby file into your loadpath.
    # 
    # This file should be in the same directory
    # as a file that defines a Sprout::Specification.
    #
    def included base
      dir, name = directory_from(caller.first)
      load_spec dir, name
    end

    private

    def directory_from base
      filename = base.split(':').shift
      parts = filename.split File::SEPARATOR
      filename = parts.pop
      dir = parts.join File::SEPARATOR
      name = filename.gsub '.rb', '.sproutspec'
      [dir, name]
    end

    def load_spec dir, name
      filename = File.join dir, name
      if(!File.exists?(filename))
        return load_spec_from_parent dir, name
      end

      Sprout::Specification.load filename
    end

    def load_spec_from_parent dir, name
      parent_dir = File.dirname(dir)
      if(parent_dir && parent_dir != dir && File.directory?(parent_dir))
        return load_spec File.dirname(dir), name
      else
        raise Sprout::Errors::UsageError.new "Sprout::Tool included, but no file named #{name} was found between the including class and the filesystem root"
      end
    end
  end

end


