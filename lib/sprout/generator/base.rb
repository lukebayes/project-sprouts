module Sprout
  module Generator

    class Base
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
        @command = Command.new self
        manifest
        @command
      end

      def directory name, &block
        @command.directory name, &block
      end

      def file name, template=nil
        @command.file name, template
      end

    end
  end
end

