
module Sprout
  class MXMLCUnit < MXMLCHelper # :nodoc:

    def initialize(args, &block)
      super
      t = define_outer_task
      t.prerequisites << player_task_name

      library :asunit3
      
      mxmlc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        t.prerequisites << :asunit3
        t.source_path << model.test_dir
        
        if(model.test_width && model.test_height)
          t.default_size = "#{model.test_width} #{model.test_height}"
        end

        yield t if block_given?
      end

      define_player
      return output
    end
    
    def create_output
      return "#{create_output_base}Runner.swf"
    end

    def create_input
      input = super
      input.gsub!(/#{input_extension}$/, "Runner#{input_extension}") 
      return input
    end
  
  end
end

def unit(args, &block)
  return Sprout::MXMLCUnit.new(args, &block)
end
