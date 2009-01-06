
module Sprout

  
  # The MXMLCCruise helper wraps up the fdb and mxmlc unit test tasks by
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   ci :cruise
  #
  # Using a specific ProjectModel instance:
  #   project_model :model
  #
  #   ci :cruise => :model
  #
  # Configuring the proxied MXMLCTask
  #   ci :cruise do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCCruise < MXMLCHelper

    def initialize(args, &block)
      super
      library :asunit3
      
      mxmlc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        t.debug = true
        t.prerequisites << :asunit3
        t.source_path << model.test_dir
        
        if(model.test_width && model.test_height)
          t.default_size = "#{model.test_width} #{model.test_height}"
        end

        yield t if block_given?
      end

      define_fdb
      t = define_outer_task
      t.prerequisites << output
      t.prerequisites << player_task_name
    end
    
    def create_output
      return "#{create_output_base}XMLRunner.swf"
    end

    def create_input
      input = super
      input.gsub!(/#{input_extension}$/, "XMLRunner#{input_extension}") 
      return input
    end
  
  end
end

def ci(args, &block)
  return Sprout::MXMLCCruise.new(args, &block)
end
