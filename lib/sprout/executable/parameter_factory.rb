
module Sprout::Executable

  ##
  # A factory to create concrete Sprout::Executable::Param
  # entities from a set of known types.
  #
  # If an unrecognized Class reference is provided
  # we will instantiate it and ensure that it
  # responds to the public members of the
  # Executable::Param interface.
  #
  # This Factory gives you the ability to create new,
  # custom parameter types by simply ensuring they are
  # available to Ruby before your executable is
  # interpreted.
  #
  # Following is an example of a custom Parameter:
  #
  #   class CustomParam < Sprout::Executable::Param
  #
  #     def to_shell
  #       "--foo-bar=#{value}"
  #     end
  #   end
  #
  # Following is an example Executable that can consume
  # the above parameter:
  #
  #   require 'custom_param'
  #
  #   class Foo
  #     include Sprout::Executable
  #
  #     add_param :name, CustomParam
  #
  #   end
  #
  # That's it, there is no need to register your custom types
  # with the Factory, just get it into your load path and
  # require it.
  #
  class ParameterFactory

    class << self

      ##
      # This factory allows us to use classes by
      # reference in the Executable interface.
      # Since there are already Ruby primitives for
      # String and File and we don't want to clobber
      # them, we use this factory to convert those
      # to the appropriate types.
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

