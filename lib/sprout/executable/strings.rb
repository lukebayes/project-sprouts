module Sprout

  module Executable

    ##
    # A collection of String values.
    #
    # @see Sprout::Executable::String
    # @see Sprout::Executable::Param
    # @see Sprout::Executable::CollectionParam
    #
    class Strings < Executable::Param
      include CollectionParam
    end
  end
end

