module Sprout

  module Executable

    ##
    # A parameter that represents a URL.
    #
    # @see Sprout::Executable::Param
    #
    # TODO: Should provide some custom validations for values
    # that should be a URL.
    #
    class Url < StringParam
    end
  end
end

