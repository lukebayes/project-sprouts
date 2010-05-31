module Sprout

  class Generator
    include Executable

    ##
    # The directory where files will be created.
    add_param :path, Path, { :default => Dir.pwd }

    ##
    # A collection of paths to look in for named templates.
    add_param :templates, Paths

    ##
    # The name of the application or component.
    add_param :name, String, { :hidden_name => true, :required => true }

    ##
    # The folder where scripts will be created.
    add_param :script, String, { :default => 'script' }

    attr_accessor :logger

    ##
    # Record the actions and trigger them
    def execute
      @logger ||= $stdout
      @command = GeneratorCommand.new self
      manifest
      @command.execute
    end

    ##
    # Rollback the generator
    def unexecute
      manifest
    end

    def say message
      logger.puts message
    end

    ##
    # TODO: Add support for arbitrary templating languages.
    # For now, just support ERB...
    def resolve_template content
      require 'erb'
      ERB.new(content, nil, '>').result(binding)
    end

    protected

    def directory name, &block
      @command.directory name, &block
    end

    def file name, template=nil
      @command.file name, template
    end

    ##
    # Shared project files that can be used by everyone.
    def create_script_dir
      directory script do
        file 'generate'
        file 'destroy'
      end
    end

    class Manifest
      attr_accessor :generator
      attr_accessor :path
      attr_accessor :parent

      def say message
        generator.say message
      end
    end

    class DirectoryManifest < Manifest
      attr_reader :children

      def initialize
        super
        @children = []
      end

      def create
        FileUtils.mkdir_p path
        say ">> Created directory: #{path}"
        children.each do |child|
          child.create
        end
      end
    end

    class FileManifest < Manifest
      attr_accessor :template
      attr_accessor :templates

      def create
        template_content = read_template
        content = generator.resolve_template template_content
        File.open path, 'w+' do |file|
          file.write content
        end
        say ">> Created file:      #{path}"
      end

      private

      def read_template
        templates.each do |template_path|
          path = File.join template_path, template_name
          if File.exists?(path)
            return File.read path
          end
        end
        raise Sprout::Errors::MissingTemplateError.new "Could not find template (#{template_name}) in any of (#{templates.inspect})"
      end

      def template_name
        template || File.basename(path)
      end
    end

    class GeneratorCommand
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
        puts ">> Command.unexecute called"
      end
    end

  end
end

