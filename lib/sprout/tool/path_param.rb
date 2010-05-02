module Sprout

  # Concrete param object for :path values
  class PathParam < ToolParam # :nodoc:

    def prepare_prerequisites
      if(value && value != belongs_to.name.to_s)
        if should_preprocess?
          @value = prepare_preprocessor_path(value)
        else
          file value
          belongs_to.prerequisites << value
        end
      end
    end
  end
end

