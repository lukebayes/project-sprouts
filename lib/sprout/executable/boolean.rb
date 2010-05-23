module Sprout

  module Executable

    # Concrete param object for :boolean values
    class Boolean < Param
      attr_accessor :show_on_false

      def initialize
        super
        @delimiter               = ' '
        @option_parser_type_name = 'BOOL'
        @show_on_false           = false
        @value                   = false
        @hidden_value            = true
      end

      def value=(value)
        super (value == "true" || value === true) ? true : false
      end
      
      def visible?
        @visible ||= value
        if(show_on_false)
          return true unless value
        else
          return @visible
        end
      end

    end
  end
end

