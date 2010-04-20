
module Sprout

  module Library

    module ClassMethods

      def add_file_target platform
        target = FileTarget.new(platform)
        begin
          yield target if block_given?
        rescue NoMethodError => no_method_error
          raise UsageError.new "There was a MethodError while loading a tool or library: #{no_method_error.message}"
        rescue ArgumentError => argument_error
          raise UsageError.new "There was an ArgumentError while loading a tool or library: #{argument_error.message}"
        end
        
        @file_targets ||= []
        @file_targets << target

        target
      end

      def file_targets
        @file_targets.dup
      end

    end

    def self.included klass
      klass.extend ClassMethods
    end
    
  end
end

