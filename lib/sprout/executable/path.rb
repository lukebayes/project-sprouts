module Sprout

  module Executable

    ##
    # Concrete Sprout::Executable::Param object for Path values.
    #
    # Path parameters will create a FileList of prerequisites by concatenating the value with
    # the +file_expression+ that is set on the parameter or Sprout::Executable.
    #
    # @see Sprout::Executable::Param
    #
    class Path < Executable::Param

      def prepare_prerequisites
        if(value && !file_is_output?(value))
          files = FileList[value + file_expression]
          files.each do |f|
            Rake::FileTask.define_task f
            belongs_to.prerequisites << f
          end
        end
      end
    end
  end
end

