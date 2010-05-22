
module Sprout::Executable

  ##
  # A factory to create concrete Executable::Param
  # entities from a set of known types.
  #
  # If an unrecognized Class reference is provided
  # we will instantiate it and ensure that it 
  # responds to the public members of the 
  # Executable::Param interface.
  class ParameterFactory

    class << self

      def create type
        return StringParam.new if type == String
        return StringsParam.new if type == Strings
        return BooleanParam.new if type == Boolean
        return FileParam.new if type == File
        return FilesParam.new if type == Files
        return PathParam.new if type == Path
        return PathsParam.new if type == Paths
        return NumberParam.new if type == Number
        return UrlsParam.new if type == Urls
        return UrlParam.new if type == Url
        type.new
      end
    end
  end
end

