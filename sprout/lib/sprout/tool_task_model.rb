
module Sprout

  class ToolTaskModel < Rake::FileTask
    include DynamicAccessors
    
    def self.define_task(args, &block)
      t = super
      yield t if block_given?
    end
    
  end

  
end

def tool_task_model(*args, &block)
  Sprout::ToolTaskModel.define_task(args, &block)
end
