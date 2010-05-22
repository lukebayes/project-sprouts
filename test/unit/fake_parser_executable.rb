
class CustomParameter < Sprout::Executable::Param; end

class FakeParserExecutable
  include Sprout::Executable

  add_param :boolean_param, Boolean
  add_param :custom_param,  CustomParameter
  add_param :file_param,    File
  add_param :files_param,   Files
  add_param :number_param,  Number
  add_param :path_param,    Path
  add_param :paths_param,   Paths
  add_param :string_param,  String
  add_param :strings_param, Strings
  add_param :urls_param,    Urls

  add_param :input,         File, { :required => true }

  add_param_alias :sp, :strings_param
end

