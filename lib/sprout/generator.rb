module Sprout

  class Generator
    include Executable

    ##
    # The directory where files will be created.
    add_param :path, Path, { :default => Dir.pwd }

    ##
    # Force the creation of files without prompting.
    add_param :force, Boolean

    ##
    # Run the generator in Quiet mode - do not write
    # status to standard output.
    add_param :quiet, Boolean

    ##
    # A collection of paths to look in for named templates.
    add_param :templates, Paths

    ##
    # The name of the application or component.
    add_param :name, String, { :hidden_name => true, :required => true }

    attr_accessor :logger

    ##
    # Record the actions and trigger them
    def execute
      prepare_command.execute
    end

    ##
    # Rollback the generator
    def unexecute
      prepare_command.unexecute
    end

    def say message
      logger.puts message.gsub("#{path}", '.')
    end

    ##
    # TODO: Add support for arbitrary templating languages.
    # For now, just support ERB...
    def resolve_template content
      require 'erb'
      ERB.new(content, nil, '>').result(binding)
    end

    protected

    def prepare_command
      @logger ||= $stdout
      @command = GeneratorCommand.new self
      manifest
      @command
    end

    def directory name, &block
      @command.directory name, &block
    end

    def file name, template=nil
      @command.file name, template
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
        if(!File.directory?(path))
          FileUtils.mkdir_p path
          say ">> Created directory: #{path}"
        else
          say ">> Skipped existing:  #{path}"
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
          say ">> Removed directory: #{path}"
          true
        else
          say ">> Skipped remove directory: #{path}"
          false
        end
      end
    end

    class FileManifest < Manifest
      attr_accessor :template
      attr_accessor :templates

      def create
        File.open path, 'w+' do |file|
          file.write resolve_template
        end
        say ">> Created file:      #{path}"
      end

      def destroy
        expected_content = resolve_template
        actual_content = File.read path
        if generator.force || actual_content == expected_content
          FileUtils.rm path
          say ">> Removed file: #{path}"
          true
        else
          say ">> Skipped remove file: #{path}"
          false
        end
      end

      private

      def resolve_template
        template_content = read_template
        generator.resolve_template template_content
      end

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
        working_dir.destroy
      end
    end

  end
end

