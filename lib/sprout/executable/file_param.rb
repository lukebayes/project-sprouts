module Sprout

  module Executable

    ##
    # Concrete param object for :file values
    #
    # This class is actually referenced in Excecutables with:
    #
    #   add_param :some_name, File
    #
    # @see Sprout::Executable::ParameterFactory
    #
    class FileParam < Param 

      def initialize
        super
        @option_parser_type_name = 'FILE'
      end

      def prepare
        super
        self.value = clean_path value
      end

      def prepare_prerequisites
        if file_task_name
          self.value ||= belongs_to.rake_task_name
          return
        end

        if prerequisite?(value)
          file value
          belongs_to.prerequisites << value
        end
      end

      def validate
        super

        if(!file_task_name && !value.nil? && !File.exists?(value))
          raise Sprout::Errors::InvalidArgumentError.new "No such file or directory - #{value}"
        end
      end

      private

      def prerequisite?(file)
        file && !file_is_output?(file)
      end
    end
  end
end

