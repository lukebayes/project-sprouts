require 'erb'

# Rake task that makes it stupid-easy to render ERB templates
# to disk. Just add parameters to the yielded object, and
# they will be available to your Template.
#
#   erb_resolver 'config/SomeFile.xml' do |t|
#     t.param1 = 'value'
#     t.other_param = 'other value'
#     t.another_param = ['a', 'b', 'c']
#   end
#
# Your erb template must be found at: 
#
#   [task_name].erb
#
# For the above example, this file would be: 
#
#   config/SomeFile.xml.erb
# 
module Sprout
  
  class ERBResolver < Rake::FileTask

    # Path to the input ERB template. This
    # value will default to the value of
    # "#{ERBResolver.output}.erb"
    attr_accessor :template

    def initialize(name, app) # :nodoc:
      super
      @context = ERBContext.new
    end

    def define(args)
    end

    def prepare
      prepare_prerequisites
    end

    # Modified from Rake::Task.execute
    def execute(args=nil)
      args ||= EMPTY_TASK_ARGS
      if application.options.dryrun
        puts "** Execute (dry run) #{name}"
        return
      end
      if application.options.trace
        puts "** Execute #{name}"
      end
      application.enhance_with_matching_rule(name) if @actions.empty?
      @actions.each do |action|
        execute_erb_task(action, args)
      end
    end
    
    def execute_erb_task(action, args=nil)
      case action.arity
      when 1
        action.call(@context)
      else
        action.call(@context, args)
      end
      
      @context.execute(template, output, args)
    end

    def self.define_task(*args, &block)
      t = super
      if(t.is_a?(ERBResolver))
        t.define(args)
        t.prepare
      end
      return t
    end

    def template
      @template ||= "#{output}.erb"
    end

    def output
      self.name
    end

    protected

    def prepare_prerequisites
      prerequisites << file(template)
      CLEAN.add(output)
    end

  end
  
  # An empty, dynamic object that will be yielded
  # to the provided block and later supplied to the
  # ERB template.
  #
  # Returning this empty object gives us the ability
  # to use parameter names in our templates even if
  # they are already used by Rake tasks (i.e. name).
  class ERBContext
    include DynamicAccessors
    
    def execute(template, output, args=nil)
      content = nil
      File.open(template, 'r') { |f| content = f.read }
      result = ERB.new(content, nil, '>').result(binding)
      File.open(output, 'w') { |f| f.write(result) }
      Log.puts ">> Created ERB output at: #{output} from: #{template}"
    end
  end
  
end

def erb_resolver(*args, &block)
  Sprout::ERBResolver.define_task(args, &block)
end
