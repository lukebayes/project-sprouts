module Sprout

  module Executable

    ##
    # Included by any parameters that represent
    # a collection of values, rather than a single
    # value.
    # 
    # Should only be included by classes that 
    # extend Sprout::Executable::Param.
    #
    # @see Sprout::Executable::Files
    # @see Sprout::Executable::Paths
    # @see Sprout::Executable::Strings
    # @see Sprout::Executable::Urls
    #
    module CollectionParam

      def initialize
        super
        @value = []
        @delimiter = "+="
        @option_parser_type_name = 'a,b,c'
      end

      ##
      # Assign the value and raise if a collection wasn't provided.
      #
      # This customization was added so that Rake tasks could help
      # users avoid accidentally clobbering a collection with equals assignments.
      #
      # The following example is incorrect and will raise an exception:
      #
      #   foo :name do |t|
      #     t.collection = 'A'
      #   end
      #
      # The following example is correct and should not raise an exception:
      #
      #   foo :name do |t|
      #     t.collection << 'A'
      #   end 
      #
      # The following example is also correct and should not raise an exception:
      #
      #   foo :name do |t|
      #     t.collection = ['A']
      #   end
      #
      def value=(val)
        if(val.is_a?(String) || !val.is_a?(Enumerable))
          message = "The #{name} property is an Enumerable. It looks like you may have used the assignment operator (=) with (#{value.inspect}) where the append operator (<<) was expected."
          raise Sprout::Errors::ExecutableError.new(message)
        end
        @value = val
      end

      ##
      # Hide the collection param if no items
      # have been added to it.
      def visible?
        (!value.nil? && value.size > 0)
      end

      ##
      # Returns a shell formatted string of the collection
      def to_shell
        prepare if !prepared?
        validate
        return '' if !visible?
        return @to_shell_proc.call(self) unless @to_shell_proc.nil?
        return value.join(' ') if hidden_name?
        return to_shell_value.collect { |val|
          "#{shell_name}#{delimiter}#{val}"
        }.join(' ')
      end

      def to_shell_value
        value
      end
    end
  end
end

