module Sprout
  module Generator

    class << self

      def register generator
        generators.unshift generator
        generator
      end

      def load environments, pkg_name=nil, version_requirement=nil
        Sprout.require_ruby_package pkg_name unless pkg_name.nil?
        environments = [environments] if environments.is_a? Symbol
        
        generator = generator_for environments, pkg_name, version_requirement
        if !generator
          message = "Unable to find generator for environments: #{environments.inspect}"
          message << " pkg_name: #{pkg_name}" unless pkg_name.nil?
          message << " and version: #{version_requirement}" unless version_requirement.nil?
          raise Sprout::Errors::MissingGeneratorError.new message
        end
        configure_instance generator
      end

      private

      def configure_instance generator
        generator
      end

      def generators
        @generators ||= []
      end

      def generator_for environments, pkg_name, version_requirement
        result = generators.select do |gen|
          environments.include?(gen.environment)
        end

        if result.size > 0
          result.first
        else
          nil
        end
      end
    end

    class Base
      include Sprout::Executable

      def self.inherited base
        Sprout::Generator.register base.new
      end

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

      set :environment, :application

      ##
      # The symbol environment name for which this generator is most 
      # appropriate. 
      # This value defaults to :application so, if you're working on an
      # application generator, you can leave it as the default.
      #
      # For all other generator types, you'll want to select the most
      # general project type that this generator may be useful in.
      #
      # Following are some example values:
      #
      #     :as3, :flex3, :flex4, :air2
      #
      # or core libraries:
      #
      #     :asunit4, :flexunit4
      #
      # or even other libraries:
      #
      #     :puremvc, :robotlegs, :swizz
      #
      attr_accessor :environment

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
        logger.puts message.gsub("#{path}", '.') unless quiet
      end

      ##
      # TODO: Add support for arbitrary templating languages.
      # For now, just support ERB...
      #
      # TODO: This is also a possible spot where those of you that don't want
      # to snuggle might put pretty-print code or some such
      # modifiers...
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

