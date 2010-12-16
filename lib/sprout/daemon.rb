
module Sprout

  ##
  # The Sprout::Daemon module exposes the Domain Specific Language
  # provided by the Sprout::Executable module, but with some
  # enhancements and modifications to support long-lived processes.
  module Daemon 

    extend Concern

    module ClassMethods

      ##
      # Add a runtime action that can be called while
      # the long-lived process is active.
      def add_action name, arguments=nil, options=nil
        options ||= {}
        options[:name] = name
        options[:arguments] = arguments
        create_action_method options
      end

      def add_action_alias alias_name, source_name
      end

      private

      def create_action_method options
        name = options[:name]
        accessor_can_be_defined_at name

        define_method(name) do |value1=nil, value2=nil|
          puts ">> #{name} called with: #{value1} #{value2}"
        end
      end

      ##
      # TODO: explode unless...
      def accessor_can_be_defined_at name
      end

    end

  end
end

