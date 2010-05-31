
module Sprout::Generator

  class Manifest
    attr_accessor :generator
    attr_accessor :path
    attr_accessor :parent

    def say message
      generator.say message
    end
  end
end
