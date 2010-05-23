module Sprout

  module Executable

    ##
    # Concrete param object for :path values
    class Path < Executable::Param

      def prepare_prerequisites
        if(value && value != belongs_to.name.to_s)
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

