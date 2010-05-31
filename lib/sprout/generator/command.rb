
module Sprout::Generator
    class Command
      attr_accessor :logger
      attr_accessor :working_dir

      attr_reader :generator

      def initialize generator
        @generator             = generator
        @working_dir           = DirectoryManifest.new
        @working_dir.generator = generator
        @working_dir.path      = generator.path
      end

      def directory path, &block
        raise Sprout::Errors::GeneratorError.new "Cannot create directory with nil path" if path.nil?
        manifest           = DirectoryManifest.new
        manifest.generator = generator
        manifest.path      = File.join(@working_dir.path, path)
        @working_dir.children << manifest
        parent = @working_dir
        @working_dir = manifest
        yield if block_given?
        @working_dir = parent
      end

      def file path, template=nil
        raise Sprout::Errors::GeneratorError.new "Cannot create file with nil path" if path.nil?
        manifest           = FileManifest.new
        manifest.generator = generator
        manifest.path      = File.join( working_dir.path, path )
        manifest.template  = template
        manifest.templates = generator.templates
        working_dir.children << manifest
      end

      def execute
        working_dir.create
      end

      def unexecute
        working_dir.destroy
      end
    end
end

