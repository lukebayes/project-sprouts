module Sprout::Generator
  class DirectoryManifest < Manifest
    attr_reader :children

    def initialize
      super
      @children = []
    end

    def create
      if !File.directory?(path)
        FileUtils.mkdir_p path
        say "Created directory: #{path}"
      else
        say "Skipped existing:  #{path}"
      end
      create_children
    end

    def destroy
      success = destroy_children

      if success && can_remove?
        FileUtils.rmdir path
        say "Removed directory: #{path}"
        true
      else
        say "Skipped remove directory: #{path}"
        false
      end
    end

    private

    def can_remove?
      File.directory?(path) && Dir.empty?(path)
    end

    def create_children
      created = children.select { |child| child.create }
      return (created.size == children.size)
    end

    def destroy_children
      destroyed = children.reverse.select { |child| child.destroy }
      return (destroyed.size == children.size)
    end
  end
end
