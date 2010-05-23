module Sprout

  module Executable

    ##
    # Concrete param object for collections of files
    class Files < Executable::Param
      include CollectionParam

      # The prepare method should be called
      # after a parameter instance has been created,
      # and configured, but before
      # prepare_prerequisites and before to_shell
      def prepare
        super
        value.collect! do |path|
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

