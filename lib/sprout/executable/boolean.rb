module Sprout

  module Executable

    ##
    # Concrete Sprout::Executable::Param object for Boolean values.
    #
    # By default Boolean parameters have their value set to false and
    # :hidden_value set to true. This means that when they are serialized
    # to the shell, they will usually be represented like:
    #
    #   --name
    #
    # Rather than:
    #
    #   --name=true
    #
    # The following example demonstrates a simple use of the Boolean
    # parameter:
    #
    #   class Foo
    #     include Sprout::Executable
    #
    #     add_param :visible, Boolean
    #   end
    #
    # @see Sprout::Executable::Param
    #
    class Boolean < Param

      ##
      # By default, the Boolean parameter will only
      # be displayed when it's value is +true+.
      #
      # Set :show_on_false to true in order to reverse
      # this rule.
      #
      #   add_param :visible, Boolean, :show_on_false => true
      #
      # Will make the following:
      #
      #   foo :name do |t|
      #     t.visible = false
      #   end
      #
      # Serialize to the shell with:
      #
      #   foo -visible=false
      # 
      attr_accessor :show_on_false

      def initialize
        super
        @delimiter               = ' '
        @option_parser_type_name = 'BOOL'
        @show_on_false           = false
        @value                   = false
        @hidden_value            = true
      end

      def default_option_parser_declaration
        [prefix, '[no-]', option_parser_name]
      end

      ##
      # Convert string representations of falsiness
      # to something more Booleaney.
      def value=(value)
        value = (value == "false" || value == false) ? false : true
        super value
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

