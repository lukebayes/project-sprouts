module Sprout

  module Executable

    ##
    # Concrete param object for :path values
    class Path < Executable::Param

      def prepare_prerequisites
        if(value && !file_is_output?(value))
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

