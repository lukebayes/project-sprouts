
module Sprout

  # Included by any parameters that represent
  # a collection of values, rather than a single
  # value.
  # 
  # Should only be included by classes that 
  # extend Sprout::ToolParam.
  #
  module CollectionParam

    # Assign the value and raise if 
    def value=(val)
      if(!val.is_a?(Enumerable))
        message = "The #{name} property is an Enumerable. It looks like you may have used the assignment operator (=) where the append operator (<<) was expected."
        raise Sprout::Errors::ToolError.new(message)
      end
      @value = val
    end

    # Collection values are initialized to an empty array by default
    def value
      @value ||= []
    end

    # Hide the collection param if no items
    # have been added to it.
    def visible?
      (!value.nil? && value.size > 0)
    end

    # Default delimiter is +=
    # This is what will appear between each name/value pair as in:
    # "source_path+=src source_path+=test source_path+=lib"
    def delimiter
      @delimiter ||= "+="
    end
    
    # Returns a shell formatted string of the collection
    def to_shell
      prepare if !prepared?
      validate
      return '' if !visible?
      return @to_shell_proc.call(self) unless @to_shell_proc.nil?
      return value.join(' ') if hidden_name?
      return value.collect { |val|
          "#{shell_name}#{delimiter}#{val}"
        }.join(' ')
    end
  end
end

