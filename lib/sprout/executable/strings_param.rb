module Sprout

  module Executable

    # Concrete param object for collections of strings
    class Strings < Executable::Param
      include CollectionParam
    end
  end
end

