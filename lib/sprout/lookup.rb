
module Sprout

  ##
  # This isn't the right name for this module...
  # It's used by Executables (or Tools), Libraries
  # and Generators. This is the way that we request
  # a bit of functionality that's stored in an external
  # RubyGem - but one that has already been installed.
  #
  # The load operation will 'require' the expected
  # feature, which will trigger a registration when
  # the Sprout::Specification is loaded by Ruby,
  # and then the remaining load operation will find
  # and return the registered entity.
  #
  # Entity, Plugin, Vine, Seed, Fruit, Plant, Tree,
  # Root, something... It's not a 'Lookup', any ideas
  # are welcomed!
  module Lookup

    extend Concern

    module ClassMethods

      def register entity
        registered_entities.unshift entity
        entity
      end

      def load name, pkg_name=nil, version_requirement=nil
        require_ruby_package pkg_name unless pkg_name.nil?
        update_registered_entities
        entity = entity_for name, pkg_name, version_requirement
        if(entity.nil?)
          message = "The requested entity: (#{name}) with pkg_name: (#{pkg_name}) and version: "
          message << "(#{version_requirement}) does not appear to be loaded."
          message << "\n\nYou probably need to update your Gemfile and run 'bundle install' "
          message << "to update your local gems."
          raise Sprout::Errors::LoadError.new message
        end
        entity
      end

      def clear_entities!
        @registered_entities = []
      end

      protected

      ##
      # Used by the Generator::Base to update inputs from 
      # empty class definitions to instances..
      def update_registered_entities
      end

      def entity_for name, pkg_name, version_requirement
        #puts ">> entity_for #{name} pkg_name: #{pkg_name} version: #{version_requirement}"
        #puts ">> with: #{registered_entities.inspect}"
        registered_entities.select do |entity|
            satisfies_platform?(entity) &&
            satisfies_pkg_name?(entity, pkg_name) &&
            (satisfies_environment?(entity, name) || satisfies_name?(entity, name)) && 
            satisfies_version?(entity, version_requirement)
        end.first
      end

      def satisfies_environment? entity, environment
        #puts ">> env: #{entity.environment} vs. #{environment}"
        environment.nil? || !entity.respond_to?(:environment) || entity.environment.to_s == environment.to_s
      end

      def satisfies_pkg_name? entity, expected
        #puts ">> pkg_name: #{entity.pkg_name} vs. #{expected}"
        expected.nil? || !entity.respond_to?(:pkg_name) || entity.pkg_name == expected
      end

      def satisfies_name? entity, expected
        #puts ">> name: #{entity.name} vs. #{expected}"
        expected.nil? || !entity.respond_to?(:name) || entity.name == expected
      end

      def satisfies_platform? entity
        #puts">> satisfies platform?"
        return true unless entity.respond_to?(:platform)
        #puts ">> platform: #{entity.platform}"
        Sprout.current_system.can_execute?(entity.platform)
      end

      def satisfies_version? entity, version_requirement=nil
        return true if version_requirement.nil?
        req_version = Gem::Requirement.create version_requirement
        req_version.satisfied_by?(Gem::Version.create(entity.pkg_version))
      end

      def require_ruby_package name
        begin
          require name
        rescue LoadError => e
          raise Sprout::Errors::LoadError.new "Could not load the required file (#{name}) - Maybe you need to run 'gem install #{name}' or maybe 'bundle install'?"
        end
      end

      ##
      # An entity has the following parameters:
      # name
      # pkg_name
      # pkg_version
      # platform
      #
      def registered_entities
        @registered_entities ||= []
      end
    end

  end
end

