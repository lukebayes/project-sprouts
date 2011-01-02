
module Sprout
  ##
  # This is where you describe your new Generator.
  class <%= input.camel_case %>Generator < Generator::Base
    
    ##
    # This is how you add a parameter to your generator
    #
    #   # @return [String] Say fwee!
    #   add_param :fwee, String, { :default => "fwee" }
    #
    def manifest
      directory input.snake_case do
        template "#{input.camel_case}<%= extension %>"
      end
    end

  end
end
