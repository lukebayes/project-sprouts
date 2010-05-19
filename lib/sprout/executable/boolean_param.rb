module Sprout

  module Executable
    # Concrete param object for :boolean values
    class BooleanParam < Param
      attr_writer :show_on_false
      
      def visible?
        @visible ||= value
        if(show_on_false)
          return true unless value
        else
          return @visible
        end
      end

      def show_on_false
        @show_on_false ||= false
      end
      
      def value
        @value ||= false
      end

    end
  end
end

