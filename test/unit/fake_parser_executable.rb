
class CustomParam < Sprout::Executable::Param; end

class FakeParserExecutable
  include Sprout::Executable

  add_param :boolean_param, BooleanParam
  add_param :custom_param,  CustomParam
  add_param :file_param,    FileParam
  add_param :files_param,   FilesParam
  add_param :number_param,  NumberParam
  add_param :path_param,    PathParam
  add_param :paths_param,   PathsParam
  add_param :string_param,  StringParam
  add_param :strings_param, StringsParam 
  add_param :symbols_param, SymbolsParam
  add_param :urls_param,    UrlsParam

  add_param :input,         FileParam, { :required => true }

  add_param_alias :sp, :strings_param
end

