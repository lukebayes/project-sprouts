module Sprout::Generator
  class DirectoryManifest < Manifest
    attr_reader :children
    attr_reader :generators

    def initialize
      super
      @children = []
      @generators = []
    end

    def create
      if !File.directory?(path)
        FileUtils.mkdir_p path
        say "Created directory: #{path}"
      else
        say "Skipped existing:  #{path}" unless(path == Dir.pwd)
      end
      create_children
      execute_generators
    end

    def destroy
      unexecute_generators
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

    def execute_generators
      generators.each do |generator|
        generator.execute
      end
    end

    def unexecute_generators
      generators.each do |generator|
        generator.unexecute
      end
    end

  end
end
