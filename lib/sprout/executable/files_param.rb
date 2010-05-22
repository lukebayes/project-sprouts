module Sprout

  module Executable
    # Concrete param object for collections of files
    class FilesParam < Executable::Param
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
        #if should_preprocess?
          #@value = prepare_preprocessor_files(value)
        #else
          value.each do |f|
            #TODO: Shouldn't this work with a FileList
            #and look more like:
            # req = FileList["#{f}/**/*"]
            # belongs_to.prerequisites << req
            #  Need to test...
            file f
            belongs_to.prerequisites << f
          end
        #end
      end

      def option_parser_type
        'a,b,c'
      end

    end
  end
end

