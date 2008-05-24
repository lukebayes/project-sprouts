
module Sprout # :nodoc:
  class MXMLCDocument < MXMLCHelper # :nodoc:
  
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
