module Sprout

  module Executable

    ##
    # Concrete Sprout::Executable::Param object for File values.
    #
    # This class is used in Sprout::Excecutable s with:
    #
    #   add_param :some_name, File
    #
    # This parameter is truly special in that whatever values
    # are sent to the File parameter will be added to the underlying
    # Rake task as prerequisites and must exist before +Sprout::Executable.execute+
    # is called - _unless_ the parameter value
    # matches the Sprout::Executable instance's +output+ value.
    #
    # Of course this will only be the case if there is a Rake
    # task wrapper for the Executable, if the Sprout::Executable
    # is being used to create a Ruby executable, then these File
    # parameters will only be validated before execution.
    #
    # @see Sprout::Executable::Param
    #
    class FileParam < Param 

      attr_accessor :file_task_name

      def initialize
        super
        @option_parser_type_name = 'FILE'
      end

      def shell_value
        clean_path value
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

