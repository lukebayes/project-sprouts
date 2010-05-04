
module Sprout

  # Concrete param object for :string values
  class StringParam < ToolParam

    def shell_value
      value.gsub(/ /, '\ ')
    end
  end

end

