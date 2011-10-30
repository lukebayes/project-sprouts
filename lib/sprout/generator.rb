require 'sprout/generator/base'
require 'sprout/generator/command'
require 'sprout/generator/manifest'
require 'sprout/generator/file_manifest'
require 'sprout/generator/template_manifest'
require 'sprout/generator/directory_manifest'

module Sprout

  ##
  #
  # = Introduction
  #
  # Sprout Generators are command line applications that are
  # installed by RubyGems and should universally provide the
  # following features:
  #
  # * Terminal tab completion to discover generators
  # * Call with no arguments to see help output
  # * Call with an +--input+ (or trailing) argument to create
  # * Call with a collection of arguments given on a previous run
  #   plus +--delete+ to undo a previous +create+
  #
  # = Usage
  #
  # == Discovery
  #
  # Sprout generators should be installed by RubyGems as command line
  # applications on your system. After installing the flashsdk gem, you
  # should have access to a variety of generators. You can find out what
  # generators are available by typing: sprout- followed by pressing the
  # <TAB> key.
  #
  # Your terminal should list out all available applications that match
  # this name.
  #
  # Some generators are expected to create new projects, others expect to
  # run within existing projects. You should be able to infer the kind of
  # generator you're looking at by the name, but if you can't just run the
  # generator with no arguments to see it's usage guidelines.
  #
  # Generators that expect to be run from within a project will usually
  # expect a file named +Gemfile+ to exist in the project root. If you're
  # trying to run Sprout generators in a project that wasn't created using
  # Sprouts, create this file and add the Rubygems that include the
  # generators that you want to use.
  #
  # == Execution
  #
  # Generators are created by human beings and sometimes they have
  # different assumptions than you do. If you're running a generator
  # within a project (especially for the first time - or since updating a
  # gem), be sure to get your project checked into version control before
  # running anything.
  #
  # Non-application generators should always be executed at the project
  # root (where you store your Rakefile, Gemfile or build.xml).
  #
  # == Deletion
  #
  # Any generator that inherits from the provided Sprout::Generators::Base
  # includes support for deletion. If you run a generator and realize that
  # you don't want the files that it created, you can always run the same
  # generator again with the same arguments, but add the --delete (or -d)
  # argument.
  #
  # == Templates
  #
  # Each time a generator is asked to locate a template, it begins a lookup
  # process. This process is designed to make it easy for you to modify any
  # template at the scope you desire.
  #
  # The lookup process will end at the first location where the expected
  # file is found.
  #
  # The search will begin with the location specified by the +-templates+
  # option (if provided) and will continue by adding '/templates' to the
  # end of each location specified by the listing for
  # Sprout::Generator#search_paths .
  #
  # = Creation
  #
  # The core Sprout gem comes with a Sprout::GeneratorGenerator. This command line
  # application is intended to be executed within a project and given the name
  # of a generator that you'd like to create.
  #
  # Try experimenting with this, and please
  # suggest[http://groups.google.com/group/projectsprouts/] any improvements to
  # the Google Group.
  #
  # ---
  #
  # Back to Home: {file:README.textile}
  #
  # Next Topic: {Sprout::Library}
  #
  # ---
  #
  # @see Sprout::GeneratorGenerator
  # @see Sprout::Library
  # @see Sprout::Executable
  # @see Sprout::Specification
  # @see Sprout::RubyFeature
  # @see Sprout::System
  #
  module Generator

    include RubyFeature

    class << self

      ##
      # Register a generator class and template path for future use.
      # Generator class names must end with "Generator", and everything
      # to the left will be used for future lookups.
      #
      # The following example will register a TestGenerator that can be
      # retrieved as +:test+.
      #
      #   Sprout::Generator.register TestGenerator
      #
      # @param generator_class [Class] A reference to the concrete Generator class.
      #   Usually these classes extend Sprout::Generator::Base.
      # @param templates_path [Directory] The path to the default templates that should
      #   be used for this generator. By default, a folder named +templates+ relative to
      #   the class definition will be used. Templates will also be searched for in a variety
      #   of locations depending on the user system. This path is simply the final searching
      #   point.
      # @return [Hash] the entity that was stored to represent the provided Generator.
      #   The entity will  generally have the keys, :class and :templates.
      def register generator_class, templates_path=nil
        generator_paths << { :class => generator_class, :templates => templates_path } unless templates_path.nil?
        super(generator_class)
      end

      ##
      # Create an instance of a concrete Generator using a +type+ argument.
      #
      # The idea is that libraries may register a generator class named,
      #   +TestGenerator+, and other generators can instantiate it without
      #   including it's Class by reference with:
      #
      #   Sprout::Generator.create_instance :test
      #
      # @param type [Symbol] A snake-cased name of the class without the Generator suffix.
      #   for example, to instantiate a generator named, +TestSuiteGenerator+, this argument
      #   would be +:test_suite+
      # @param options [Hash] deprecated - please remove this argument wherever it's found.
      def create_instance type, options=nil
        class_name = "#{type.to_s.camel_case}Generator"
        registered_entities.each do |entity|
          if(entity.to_s.match(/::#{class_name}$/) || entity.to_s.match(/^#{class_name}$/))
            return entity.new
          end
        end
        raise Sprout::Errors::MissingGeneratorError.new "Could not find any generator named: (#{class_name}). Perhaps you need to add a RubyGem to your Gemfile?"
      end

      ##
      # Retrieve the root template folder for the provided Class.
      #
      # This method will look for a templates folder next to
      # each superclass in the inheritance chain.
      #
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
      # Returns a new collection of paths to search within for generator
      # declarations and more importantly, folders named, 'templates'.
      #
      # The collection of search_paths will be a subset of the following
      # that will include only those directories that exist:
      #
      #     ./config/generators
      #     ./vendor/generators
      #     ~/Library/Sprouts/1.0/generators                          # OS X only
      #     ~/.sprouts/1.0/generators                                 # Unix only
      #     [USER_HOME]/Application Data/Sprouts/cache/1.0/generators # Windows only
      #     ENV['SPROUT_GENERATORS']                                  # Only if defined
      #     [Generator Declaration __FILE__]
      #     [Generator SUPER-class declaration __FILE__]
      #     [Repeat step above until there is no super-class]
      #
      # When the generators attempt to resolve templates, each of the preceding
      # folders will be scanned for a child directory named 'templates'. Within
      # that directory, the requested template name will be scanned and the first
      # found template file will be used. This process will be repeated for each
      # template file that is requested.
      #
      # The results of this search are not cached, so you can override a single
      # template and leave the rest wherever the generator has defined them.
      #
      # @return [Array] of paths
      #
      def search_paths
        # NOTE: Do not cache this list, specific generators
        # will modify it with their own lookups
        create_search_paths.select { |path| File.directory?(path) }
      end

      def create_search_paths
        paths = [
                  File.join('config', 'generators'),
                  File.join('vendor', 'generators'),
                  Sprout.generator_cache
                ]
        paths << ENV['SPROUT_GENERATORS'] unless ENV['SPROUT_GENERATORS'].nil?
        paths
      end

      private

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
  end
end

