
module Sprout # :nodoc:
  class MXMLCStyleSheet < MXMLCHelper # :nodoc:
  
    def initialize(args, &block)
      super
      outer = define_outer_task
      
      mxmlc output do |t|
        configure_mxmlc t
        yield t if block_given?
      end
      
      outer.prerequisites << output
      return output
    end
    
    protected
    
    def create_input
      return File.join(@model.src_dir, @model.project_name + 'Skin') + input_extension
    end
    
    def create_output
      return "#{create_output_base}Skin.swf"
    end

    def input_extension
      return '.css'
    end
    
    
  end
end

def stylesheet(args, &block)
    return Sprout::MXMLCStyleSheet.new(args, &block)
end
