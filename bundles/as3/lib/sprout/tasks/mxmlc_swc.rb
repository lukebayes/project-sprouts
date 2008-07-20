
module Sprout # :nodoc:

  # The MXMLCSWC helper wraps a compc task to create
  # a SWC library.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   swc :swc
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   swc :swc => :model
  #
  # Configuring the proxy MXMLCTask
  #   swc :swc do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCSWC < MXMLCHelper
  
    def initialize(args, &block)
      super
      outer_task = define_outer_task
      
      compc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        t.input = input
        yield t if block_given?
      end

      outer_task.prerequisites << output
      return outer_task
    end

    def create_output
      return "#{create_output_base}.swc"
    end
    
    def create_input
      return @model.project_name
    end
  end
end

def swc(args, &block)
    Sprout::MXMLCSWC.new(args, &block)
end
