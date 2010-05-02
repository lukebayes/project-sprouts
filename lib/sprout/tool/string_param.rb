
module Sprout

  # Concrete param object for :string values
  class StringParam < ToolParam # :nodoc:

    def shell_value
      value.gsub(/ /, "\ ")
    end
  end

  # Concrete param object for :symbol values
  # like class names
  class SymbolParam < ToolParam # :nodoc:
  end

  # Concrete param object for :url values
  class UrlParam < ToolParam # :nodoc:
  end

  # Concrete param object for :number values
  class NumberParam < ToolParam # :nodoc:
  end

  # Concrete param object for :file values
  class FileParam < ToolParam # :nodoc:

    def prepare_prerequisites
      if(value && value != belongs_to.name.to_s)
        if(should_preprocess?)
          @value = prepare_preprocessor_file(value)
        else
          file value
          belongs_to.prerequisites << value
        end
      end
    end
  end
end

