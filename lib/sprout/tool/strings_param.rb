module Sprout
  # Concrete param object for collections of strings
  class StringsParam < TaskParam # :nodoc:

    def value=(val)
      if(val.is_a?(String))
        message = "The #{name} property is an Array, not a String. It looks like you may have used the assignment operator (=) where the append operator (<<) was expected."
        raise ToolTaskError.new(message)
      end
      @value = val
    end

    # Files lists are initialized to an empty array by default
    def value
      @value ||= []
    end

    # By default, the FilesParams will not appear in the shell
    # output if there are zero items in the collection
    def visible?
      @visible ||= (value && value.size > 0)   
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

      result = []
      value.each do |str|
        result << "#{shell_name}#{delimiter}#{str}"
      end
      return result.join(' ')
    end
  end
end

