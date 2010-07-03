module Sprout

  module Generator
    include RubyFeature

    class << self

      def register generator_class, templates_path=nil
        generator_paths << { :class => generator_class, :templates => templates_path } unless templates_path.nil?
        super(generator_class)
      end

      def create_instance type, options=nil
        class_name = "#{type.to_s.camel_case}Generator"
        registered_entities.each do |entity|
          if(entity.to_s.match /::#{class_name}$/ || entity.to_s.match /^#{class_name}$/)
            return entity.new
          end
        end
        raise Sprout::Errors::MissingGeneratorError.new "Could not find any generator named: (#{class_name}). Perhaps you need to add a RubyGem to your Gemfile?"
      end

      def template_folder_for clazz
        # Search the potential matches in reverse order
        # because subclasses have registered AFTER their
        # superclasses and superclasses match the ===
        # check...
        generator_paths.reverse.each do |options|
          if options[:class] === clazz
            return options[:templates]
          end
        end
        nil
      end

      ##
      # Returns a new collection of paths to search within for generator declarations
      # and more importantly, folders named, 'templates'.
      #
      # The collection of search_paths will be a subset of the following
      # that will include only those directories that exist:
      #
      #     ./config/generators
      #     ./vendor/generators
      #     ~/Library/Sprouts/1.0/generators                    # OS X only
      #     ~/.sprouts/1.0/generators                           # Unix only
      #     [USER_HOME]/Application Data/Sprouts/cache/1.0/generators # Windows only
      #     ENV['SPROUT_GENERATORS']                                  # Only if defined
      #     [Generator Declaration __FILE__]/templates
      #
      # When the generators attempt to resolve templates, each of the preceding
      # folders will be scanned for a child directory named 'templates'. Within
      # that directory, the requested template name will be scanned and the first
      # found template file will be used. This process will be repeated for each
      # template file that is requested. 
      #
      # The idea is that you may wish to override some template files that a 
      # generator creates, but leave others unchanged.
      #
      def search_paths
        # NOTE: Do not cache this list, specific generators
        # will modify it with their own lookups
        create_search_paths.select { |path| File.directory?(path) }
      end

      private

      def create_search_paths
        paths = [
                  File.join('config', 'generators'),
                  File.join('vendor', 'generators'),
                  Sprout.generator_cache
                ]
        paths << ENV['SPROUT_GENERATORS'] unless ENV['SPROUT_GENERATORS'].nil?
        paths
      end

      ##
      # I know this seems weird - but we can't instantiate the classes
      # during registration because they register before they've been fully
      # interpreted...
      def update_registered_entities
        registered_entities.collect! do |gen|
          (gen.is_a?(Class)) ? gen.new : gen
        end
      end

      def configure_instance generator
        generator
      end

      def generator_paths
        @generator_paths ||= []
      end

    end

    class Base
      include Sprout::Executable

      def self.inherited base
        # NOTE: We can NOT instantiate the class here,
        # because only it's first line has been interpreted, if we 
        # instantiate here, none of the code declared in the class body will
        # be associated with this instance.
        #
        # Go ahead and register the class and update instances afterwards.
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
        return prepare_command.unexecute if destroy
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

      ##
      # Returns a collection of templates that were provided on the 
      # command line, followed by templates that are created by a 
      # concrete generator, followed by the 
      # Sprout::Generator.search_paths + 'templates' folders.
      #
      def template_paths
        templates << Sprout::Generator::template_folder_for(self)
        templates.concat default_search_paths
      end

      protected

      def default_search_paths
        Sprout::Generator.search_paths.collect { |path| File.join(path, 'templates') }
      end

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

      def template name, template=nil
        @command.template name, template
      end

      def generator name, options={}
        instance = Sprout::Generator.create_instance name, options
        instance.from_hash to_hash.merge(options)
        instance.logger = logger
        instance.execute
      end

      private

      def self.template_from_caller caller_string
        file = Sprout.file_from_caller caller_string
        File.join(File.dirname(file), 'templates')
      end

    end
  end
end

