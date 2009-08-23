
module Sprout # :nodoc:
  
  # The MXMLCDebug helper wraps up the flashplayer and mxmlc tasks by
  # using either a Singleton or provided ProjectModel instance.
  #
  # The simple case that uses a Singleton ProjectModel:
  #   debug :debug
  #
  # Using a ProjectModel instance:
  #   project_model :model
  #
  #   debug :debug => :model
  #
  # Configuring the proxied Sprout::MXMLCTask
  #   debug :debug do |t|
  #     t.link_report = 'LinkReport.rpt'
  #   end
  #
  class MXMLCDebug < MXMLCHelper
  
    def initialize(args, &block)
      super

      t = define_outer_task

      mxmlc output do |t|
        configure_mxmlc t
        configure_mxmlc_application t
        yield t if block_given?
      end

      define_player
      
      t.prerequisites << output
      t.prerequisites << player_task_name
    end
    
  end
end

def debug(args, &block)
    return Sprout::MXMLCDebug.new(args, &block)
end
