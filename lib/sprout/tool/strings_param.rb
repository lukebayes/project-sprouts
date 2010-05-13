module Sprout

  module Tool
    # Concrete param object for collections of strings
    class StringsParam < Tool::Param
      include CollectionParam
    end
  end
end

