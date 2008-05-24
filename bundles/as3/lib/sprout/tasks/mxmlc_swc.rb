
module Sprout # :nodoc:
  class MXMLCSWC < MXMLCHelper # :nodoc:
  
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
