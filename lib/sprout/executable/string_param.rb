module Sprout

  module Executable
    # Concrete param object for :string values
    class StringParam < Executable::Param

      def shell_value
        value.gsub(/ /, '\ ')
      end

      def option_parser_name
        "--#{name.to_s.gsub('_', '-')}"
      end

    end
  end
end

