
module Sprout::Executable

  class Parser

    def parse options
      cleaned = clean_options options
    end

    private

    def clean_options options
      options.collect do |option|
        clean_option option
      end
    end

    def clean_option option
      if(option.match /\=/)
        return create_parameter option.split('=') 
      end
      result
    end

    def create_parameter parts
      param = Parameter.new
      param.name = parts.first
      param.value = parts.last
      param
    end
  end

  class Parameter
    attr_accessor :value

    def name=(name)
      name.strip!
      name.gsub!(/^-+/, '')
      name.gsub!(/-/, '_')
      @name = name.to_sym
    end

    def name
      @name
    end

  end
end

