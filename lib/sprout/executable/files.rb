module Sprout

  module Executable

    ##
    # Concrete param object for collections of files
    #
    # See also Sprout::Executable::File
    #
    # See also Sprout::Executable::Param
    #
    # See also Sprout::Executable::CollectionParam
    #
    class Files < Executable::Param
      include CollectionParam

      def to_shell_value
        value.collect do |path|
          clean_path path
        end
      end

      def prepare_prerequisites
        value.each do |f|
          file f
          belongs_to.prerequisites << f
        end
      end

    end
  end
end

