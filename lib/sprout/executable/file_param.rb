module Sprout

  module Executable
    # Concrete param object for :file values
    class FileParam < Param 

      def prepare
        super
        self.value = clean_path value
      end

      def prepare_prerequisites
        if(prerequisite?(value))
          #if(should_preprocess?)
            #@value = prepare_preprocessor_file(value)
          #else
            file value
            belongs_to.prerequisites << value
          #end
        end
      end

      def validate
        super

        if(!value.nil? && !File.exists?(value))
          raise Sprout::Errors::InvalidArgumentError.new "No such file or directory - #{value}"
        end
      end

      private

      def prerequisite?(file)
        (file && file != belongs_to.name.to_s)
      end

    end
  end
end

