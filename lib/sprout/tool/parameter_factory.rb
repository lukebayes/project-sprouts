
module Sprout

  class ParameterFactory

    class << self

      def create type
        param = instantiate type
        yield param if block_given?
        param
      end

      private

      def instantiate type
        return BooleanParam.new if type == :boolean
        return FileParam.new    if type == :file
        return FilesParam.new   if type == :files
        return NumberParam.new  if type == :number
        return PathParam.new    if type == :path
        return PathsParam.new   if type == :paths
        return StringParam.new  if type == :string
        return StringsParam.new if type == :strings
        return SymbolsParam.new if type == :symbols
        return UrlParam.new    if type == :url
        return UrlsParam.new    if type == :urls

        param = resolve_parameter(type.to_s)
        return param unless param.nil?
        raise Sprout::Errors::UsageError.new "ParameterFactory.create called with unknown type: #{type}"
      end

      def resolve_parameter type_str
        [type_str, type_str + "_param"].each do |type|
          instance = attempt_to_instantiate type
          return instance unless instance.nil?
        end
        nil
      end

      def attempt_to_instantiate type
        camel_cased = type.to_s.camel_case
        begin
          constructor = Object.const_get camel_cased
          return constructor.new unless constructor.nil?
        rescue NameError
          return nil
        end
      end
    end
  end
end

