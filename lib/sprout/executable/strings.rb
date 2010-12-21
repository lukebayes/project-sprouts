module Sprout

  module Executable

    ##
    # A collection of String values.
    #
    # See also Sprout::Executable::String
    #
    # See also Sprout::Executable::Param
    #
    # See also Sprout::Executable::CollectionParam
    #
    class Strings < Executable::Param
      include CollectionParam
    end
  end
end

