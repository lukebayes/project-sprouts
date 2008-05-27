
module Sprout # :nodoc:
  
  # The MXMLCStylesheet helper simplifies the creation of
  # runtime CSS stylesheet SWFs for Flex applications.
  # This task can work using either a Singleton or 
  # provided ProjectModel instance
  #
  # The simple case that uses a Singleton ProjectModel:
  #   stylesheet :skin
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   stylesheet :skin => :model
  #
  # Configuring the proxy MXMLCTask
  #   stylesheet :skin do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCStyleSheet < MXMLCHelper
  
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
