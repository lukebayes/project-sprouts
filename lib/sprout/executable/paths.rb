module Sprout

  module Executable

    ##
    # A collection of Paths.
    #
    # See also Sprout::Executable::Path
    #
    # See also Sprout::Executable::Param
    #
    # See also Sprout::Executable::CollectionParam
    #
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

