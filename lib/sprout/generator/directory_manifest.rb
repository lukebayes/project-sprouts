module Sprout::Generator
  class DirectoryManifest < Manifest
    attr_reader :children

    def initialize
      super
      @children = []
    end

    def create
      if(!File.directory?(path))
        FileUtils.mkdir_p path
        say "Created directory: #{path}"
      else
        say "Skipped existing:  #{path}"
      end
      children.each do |child|
        child.create
      end
    end

    def destroy
      success = true
      children.each do |child|
        if !child.destroy
          success = false
        end
      end

      if success && File.directory?(path) && Dir.empty?(path)
        FileUtils.rm_rf path
        say "Removed directory: #{path}"
        true
      else
        say "Skipped remove directory: #{path}"
        false
      end
    end
  end
end
