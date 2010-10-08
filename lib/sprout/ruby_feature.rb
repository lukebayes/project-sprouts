
module Sprout

  ##
  # This class represents a Feature that is written in
  # Ruby code that exists on the other side of the
  # Ruby load path.
  #
  # The idea here, is that one can +include+ the Sprout::RubyFeature
  # module into their concrete class, and then accept
  # requests to +register+ and +load+ from clients that
  # are interested in pluggable features.
  #
  # An example is as follows:
  #
  #     require 'sprout'
  #
  #     class MyClass
  #       include Sprout::RubyFeature
  #     end
  #
  # In some other Ruby file:
  #
  #     MyClass.load :other, 'other_gem', '>= 1.0pre'
  #
  # In the desired Ruby file:
  #
  #     class OtherClass
  #       include Sprout::Executable
  #
  #       set :name, :other
  #       set :pkg_name, 'other_gem'
  #       set :pkg_version, '1.0.pre'
  #
  #       # do something...
  #     end
  #
  #     MyClass.register OtherClass.new
  #
  module RubyFeature

    extend Concern

    module ClassMethods

      ##
      # Register a new feature for future lookups
      def register entity
        validate_registration entity
        registered_entities.unshift entity
        entity
      end

      ##
      # Load a feature by name.
      def load name_or_names, pkg_name=nil, version_requirement=nil
        entity = entity_for name_or_names, pkg_name, version_requirement
        if(entity.nil?)
          # Try to require the pkg_name:
          require_ruby_package pkg_name unless pkg_name.nil?
          # Update any entities that registered from our require:
          update_registered_entities
          # search for the requested entity:
          entity = entity_for name_or_names, pkg_name, version_requirement
        end

        if(entity.nil?)
          message = "The requested entity: (#{name_or_names}) with pkg_name: (#{pkg_name}) and version: "
          message << "(#{version_requirement}) does not appear to be loaded."
          message << "\n"
          message << "We did find (#{registered_entities.size}) registered entities in that package:\n\n"
          registered_entities.each do |other|
            message << ">> name: (#{other.name}) pkg_name: (#{other.pkg_name}) pkg_version: (#{other.pkg_version})\n"
          end
          message << "\n\nYou may need to update your Gemfile and run 'bundle install' "
          message << "to update your local gems.\n\n"
          raise Sprout::Errors::LoadError.new message
        end
        entity
      end

      def clear_entities!
        @registered_entities = []
      end

      protected

      def validate_registration entity
        if(!entity.respond_to?(:name) || entity.name.nil?)
          raise Sprout::Errors::UsageError.new "Cannot register a RubyFeature without a 'name' getter"
        end
      end

      #
      # Used by the Generator::Base to update inputs from 
      # empty class definitions to instances..
      def update_registered_entities
      end

      def entity_for name_or_names, pkg_name, version_requirement
        # These commented blocks help immensely when debugging
        # loading and registration issues, please leave them here:
        #puts "+++++++++++++++++++++++++++"
        #puts ">> entity_for #{name_or_names} pkg_name: #{pkg_name} version: #{version_requirement}"
        #registered_entities.each do |entity|
          #puts ">> entity: #{entity.name} pkg_name: #{entity.pkg_name} version: #{entity.pkg_version}"
        #end
        registered_entities.reverse.select do |entity|
            satisfies_name?(entity, name_or_names) && 
            satisfies_platform?(entity) &&
            satisfies_pkg_name?(entity, pkg_name) &&
            satisfies_version?(entity, version_requirement)
        end.first
      end

      def satisfies_environment? entity, environment
        #puts ">> env: #{entity.environment} vs. #{environment}"
        environment.nil? || !entity.respond_to?(:environment) || entity.environment.to_s == environment.to_s
      end

      def satisfies_pkg_name? entity, expected
        #puts ">> pkg_name: #{entity.pkg_name} vs. #{expected}"
        expected.nil? || !entity.respond_to?(:pkg_name) || entity.pkg_name.to_s == expected.to_s
      end

      def satisfies_name? entity, expected
        #puts ">> name: #{entity.name} vs. #{expected}"
        return true if expected.nil? || !entity.respond_to?(:name)
        if expected.is_a?(Array)
          return expected.include? entity.name
        end
        return expected.to_s == entity.name.to_s
      end

      def satisfies_platform? entity
        #puts">> satisfies platform?"
        return true if !entity.respond_to?(:platform) || entity.platform.nil?
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

##
# Mixin on the Rake::Task so
# that our concrete entities
# can interoperate with some
# knowledge of each other.
class Rake::Task
  attr_accessor :sprout_type
end
