
module Sprout

  class ParameterFactory

    def self.create type
      param = instantiate type
      yield param if block_given?
      param
    end

    private

    def self.instantiate type
      return BooleanParam.new if type == :boolean
      return FileParam.new    if type == :file
      return FilesParam.new   if type == :files
      return PathParam.new    if type == :path
      return PathsParam.new   if type == :paths
      return StringParam.new  if type == :string
      return StringsParam.new if type == :strings
      return SymbolsParam.new if type == :symbols
      return UrlsParam.new    if type == :urls
    end
  end
end

