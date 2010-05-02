
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
      return false if value.size == 0
      super
    end

    # Default delimiter is +=
    # This is what will appear between each name/value pair as in:
    # "source_path+=src source_path+=test source_path+=lib"
    def delimiter
      @delimiter ||= "+="
    end
    
    # Returns a shell formatted string of the collection
    def to_shell
      return @to_shell_proc.call(self) if(!@to_shell_proc.nil?)

      value.collect { |val|
        "#{shell_name}#{delimiter}#{val}"
      }.join(' ')
    end
  end
end

