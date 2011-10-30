module Sprout

  module Executable

    ##
    # A parameter with a String value.
    #
    # Any spaces in the value will be escaped when
    # returned to a shell.
    #
    # @see Sprout::Executable::Param
    #
    class StringParam < Executable::Param

      def shell_value
        value.gsub(/ /, '\ ')
      end

    end
  end
end

