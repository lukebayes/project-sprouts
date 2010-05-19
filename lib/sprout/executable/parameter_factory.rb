##
# Used to create new Parameter instances for Sprout::Executable.
#
class Sprout::Executable::ParameterFactory

  class << self

    ##
    # Create an new Parameter by type.
    #
    # @type Symbol
    #
    def create type
      param = instantiate type
      yield param if block_given?
      param
    end

    private

    def instantiate type
      param = resolve_sprout_parameter type.to_s
      return param unless param.nil?

      param = resolve_unknown_parameter(type.to_s)
      return param unless param.nil?
      raise Sprout::Errors::UsageError.new "ParameterFactory.create called with unknown type: #{type}"
    end

    def resolve_sprout_parameter type_str
      type_str = "#{type_str}_param"
      attempt_to_instantiate Sprout::Executable, type_str
    end

    def resolve_unknown_parameter type_str
      [type_str, "#{type_str}_param"].each do |type|
        instance = attempt_to_instantiate Object, type
        return instance unless instance.nil?
      end
      nil
    end

    def attempt_to_instantiate from, type
      camel_cased = type.to_s.camel_case
      begin
        constructor = from.const_get camel_cased
        return constructor.new unless constructor.nil?
      rescue NameError
        return nil
      end
    end
  end
end

