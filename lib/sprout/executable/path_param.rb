module Sprout

  module Executable

    class Path; end

    ##
    # Concrete param object for :path values
    class PathParam < Executable::Param

      def prepare_prerequisites
        if(value && value != belongs_to.name.to_s)
          if should_preprocess?
            @value = prepare_preprocessor_path(value)
          else
            files = FileList[value + file_expression]
            files.each do |f|
              file f
              belongs_to.prerequisites << f
            end
          end
        end
      end
    end
  end
end

