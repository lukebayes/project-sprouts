
module Sprout

  
  # The MXMLCUnit helper wraps up fdb and mxmlc unit test tasks by
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   unit :test
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   unit :test => :model
  #
  # Configuring the proxy MXMLCTask
  #   unit :test do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCUnit < MXMLCHelper

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

      define_player
      t = define_outer_task
      t.prerequisites << player_task_name
    end
    
    def create_output
      return "#{create_output_base}Runner.swf"
    end

    def create_input
      input = super
      input.gsub!(/#{input_extension}$/, "Runner#{input_extension}") 
      return input
    end
  
  end
end

def unit(args, &block)
  return Sprout::MXMLCUnit.new(args, &block)
end
