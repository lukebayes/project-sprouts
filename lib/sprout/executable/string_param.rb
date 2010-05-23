module Sprout

  module Executable

    # Concrete param object for :string values
    class StringParam < Executable::Param

      def shell_value
        value.gsub(/ /, '\ ')
      end

    end
  end
end

