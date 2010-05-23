module Sprout

  module Executable

    ##
    # Concrete param object for collections of paths
    class Paths < Files 

      def prepare_prerequisites
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

