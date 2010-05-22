module Sprout

  module Executable

    class Paths; end

    # Concrete param object for collections of paths
    class PathsParam < FilesParam # :nodoc:

      def prepare_prerequisites
        if should_preprocess?
          @value = prepare_preprocessor_paths(value)
        else
          value.each do |path|
            files = FileList[path + file_expression]
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

