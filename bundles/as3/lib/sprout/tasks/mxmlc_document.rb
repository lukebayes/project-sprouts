
module Sprout # :nodoc:

  # The MXMLCDocument helper wraps up the asdoc task
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   document :doc
  #
  # Using a ProjectModel instance:
  #   model = Sprout::ProjectModel.setup
  #
  #   document :doc => model
  #
  # Configuring the proxy ASDocTask
  #   document :doc do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCDocument < MXMLCHelper
  
    def initialize(args, &block)
      super
      outer = define_outer_task
      
      asdoc output => input do |t|
        t.output = 'doc'
        yield t if block_given?
      end
      
      outer.prerequisites << output
    end
    
    def create_output
      return File.join(model.doc_dir, 'index.html')
    end

    def create_input
      return "#{create_output_base}.swf"
    end
    
  end
end

def document(args, &block)
    Sprout::MXMLCDocument.new(args, &block)
end
