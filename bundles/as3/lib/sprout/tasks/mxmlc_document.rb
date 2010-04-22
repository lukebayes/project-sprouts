
module Sprout # :nodoc:

  # The MXMLCDocument helper wraps up the asdoc task
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   document :asdoc
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   document :asdoc => :model
  #
  # Configuring the proxy ASDocTask
  #   document :asdoc do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCDocument < MXMLCHelper
  
    def initialize(args, &block)
      super
      
      asdoc task_name do |t|
        configure_mxmlc(t, true)
        t.output = model.doc_dir
        t.doc_classes << input
        t.main_title = model.project_name
        yield t if block_given?
      end
      
    end
    
    def create_input
      return File.basename(super).split('.')[0]
    end
    
  end
end

def document(args, &block)
    Sprout::MXMLCDocument.new(args, &block)
end
