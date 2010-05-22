module Sprout

  module Executable

    class Strings; end

    # Concrete param object for collections of strings
    class StringsParam < Executable::Param
      include CollectionParam
    end
  end
end

