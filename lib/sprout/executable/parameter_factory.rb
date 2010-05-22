
module Sprout::Executable

  ##
  # A factory to create concrete Executable::Param
  # entities from a set of known types.
  #
  # If an unrecognized Class reference is provided
  # we will instantiate it and ensure that it 
  # responds to the public members of the 
  # Executable::Param interface.
  class ParameterFactory

    class << self

      def create type
        # Didn't want to clobber the stdlib references
        # to these two important data types...
        # But wanted to keep the add_param interface
        # clean and simple.
        return StringParam.new if type == String
        return FileParam.new if type == File
        type.new
      end
    end
  end
end

