
module Sprout
  class MXMLCDeploy < MXMLCHelper # :nodoc:

    def initialize(args, &block)
      super
      t = define_outer_task
      t.prerequisites << player_task_name
      
      out_task = mxmlc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        t.optimize            = true
        t.warnings            = false
        t.verbose_stacktraces = false
        
        block.call t if !block.nil?
      end
      
      task player_task_name => output
      return out_task
    end

    def create_input
      return File.join(@model.src_dir, @model.project_name) + input_extension
    end
    
    def create_output
      return "#{create_output_base}.swf"
    end
  
  end
end

def deploy(args, &block)
  return Sprout::MXMLCDeploy.new(args, &block)
end
