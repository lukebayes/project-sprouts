module Sprout
  module Generator

    class Base < Sprout::Executable::Base

      def self.inherited base
        # NOTE: We can NOT instantiate the class here,
        # because only it's first line has been interpreted, if we
        # instantiate here, none of the code declared in the class body will
        # be associated with this instance.
        #
        # Go ahead and register the class and update instances later...
        Sprout::Generator.register base, template_from_caller(caller.first)
      end

      ##
      # The directory where files will be created.
      add_param :path, Path, { :default => Dir.pwd }

      ##
      # Insteast of creating, destroy the files.
      add_param :destroy, Boolean

      ##
      # Force the creation of files without prompting.
      add_param :force, Boolean

      ##
      # Run the generator in Quiet mode - do not write
      # status to standard output.
      add_param :quiet, Boolean

      ##
      # Display the paths this generator will use to look
      # for templates on this system and exit.
      add_param :show_template_paths, Boolean

      ##
      # A collection of paths to look in for named templates.
      add_param :templates, Paths

      ##
      # The primary input for the application or component.
      add_param :input, String, { :hidden_name => true, :required => true }

      ##
      # Set the default name for generators.
      set :name, :application

      ##
      # The symbol name for which this generator is most
      # appropriate.
      #
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
      attr_accessor :name
      attr_accessor :logger
      attr_accessor :pkg_name
      attr_accessor :pkg_version

      ##
      # Record the actions and trigger them
      def execute
        return do_show_template_paths if show_template_paths
        return prepare_command.unexecute if destroy
        prepare_command.execute
      end

      def validate
        return true if show_template_paths
        super
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

      ##
      # Returns a collection of templates that were provided on the
      # command line, followed by templates that are created by a
      # concrete generator, followed by the
      # Sprout::Generator.search_paths + 'templates' folders.
      #
      def template_paths
        create_template_paths
      end

      def create_template_paths
        paths = templates.dup
        paths = paths.concat Sprout::Generator.search_paths
        paths << Sprout::Generator::template_folder_for(self)
      end

      protected

      def do_show_template_paths
        @logger ||= $stdout
        message = "The following paths will be checked for templates:\n"

        paths = ["--templates+=[value]"]
        paths = paths.concat Sprout::Generator.create_search_paths
        paths << "ENV['SPROUT_GENERATORS']"
        paths << Sprout::Generator::template_folder_for(self)

        message << "  * "
        message << paths.join("\n  * ")
        say message
        message
      end

      def default_search_paths
        Sprout::Generator.search_paths.collect { |path| File.join(path, 'templates') }
      end

      def prepare_command
        @logger ||= $stdout
        @command = Command.new self
        @command.logger = logger
        manifest
        @command
      end

      def directory name, &block
        @command.directory name, &block
      end

      def file name, template=nil
        @command.file name, template
      end

      def template name, template=nil
        @command.template name, template
      end

      def generator name, options={}
        @command.generator name, to_hash.merge(options)
      end

      private

      def self.template_from_caller caller_string
        file = Sprout.file_from_caller caller_string
        File.join(File.dirname(file), 'templates')
      end

    end
  end
end

