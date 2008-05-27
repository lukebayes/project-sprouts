
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
      t = define_outer_task
      
      compc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        yield t if block_given?
      end

      t.prerequisites << output
      return t
    end

    def create_output
      return "#{create_output_base}.swc"
    end
    
  end
end

def swc(args, &block)
    Sprout::MXMLCSWC.new(args, &block)
end
