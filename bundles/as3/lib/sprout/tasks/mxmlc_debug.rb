
module Sprout # :nodoc:
  class MXMLCDebug < MXMLCHelper # :nodoc:
  
    def initialize(args, &block)
      super
      mxmlc output do |t|
        t.debug = true
        configure_mxmlc t
        configure_mxmlc_application t
        yield t if block_given?
      end

      define_player
      
      t = define_outer_task
      t.prerequisites << player_task_name
    end
    
  end
end

def debug(args, &block)
    return Sprout::MXMLCDebug.new(args, &block)
end
