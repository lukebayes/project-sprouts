
module Sprout

  ##
  # The Sprout::Daemon module exposes the Domain Specific Language
  # provided by the Sprout::Executable module, but with some
  # enhancements and modifications to support long-lived processes.
  #
  # Any class that includes Daemon should first include 
  # Executable. This is an admittedly smelly constraint, but it works
  # for now.
  #
  #   class Foo
  #     include Sprout::Executable
  #     include Sprout::Daemon
  #   end
  #
  module Daemon

    extend Concern

    module ClassMethods

      ##
      # Add a runtime action that can be called while
      # the long-lived process is active.
      def add_action name, arguments=nil, options=nil
        options ||= {}
        options[:name] = name
        options[:arguments] = arguments
        create_action_method options
      end

      def add_action_alias alias_name, source_name
      end

      private

      def create_action_method options
        name = options[:name]
        accessor_can_be_defined_at name

        define_method(name) do |*params|
          puts ">> #{name} called with: #{params.inspect}"
          if(!options[:writer].nil?)
            value = self.send(options[:writer], *params)
          end
          action_stack << { :name => name, :params  => params }
        end
      end

      ##
      # TODO: explode unless...
      def accessor_can_be_defined_at name
      end

    end

    module InstanceMethods

      ##
      # The prompt expression for this daemon process.
      # When executing a series of commands, the
      # wrapper will wait until it reads this expression
      # on stdout before continuing the series.
      #
      # For FDB, this value is set like:
      #
      #   set :prompt, /^\(fdb\) /
      #
      attr_accessor :prompt

      attr_reader :action_stack

      def initialize
        super
        @action_stack = []
      end

      def execute
        thread, runner = super
        execute_actions runner
        thread.join
      end

      protected

      ##
      # Override this method so that we 
      # create a 'task' instead of a 'file' task.
      def create_outer_task *args
        task *args do
          execute
        end
      end

      ##
      # Override this method (Executable)
      # so that we 
      # create the process in a thread 
      # in order to read and write to it.
      def system_execute binary, params
        Sprout.current_system.execute_thread binary, params
      end

      private

      def execute_actions runner
        puts "---------------"
        puts ">> execute_actions with: #{runner}"
        puts "---------------"
        action_stack.each do |action|
          execute_action runner, action_stack.shift
        end
      end

      def execute_action runner, action
        wait_for_prompt runner
        puts ">> action: #{action.inspect}"
      end

      def wait_for_prompt runner, expected_prompt=nil
        expected_prompt = expected_prompt || prompt
        puts ">> wait for prompt with: #{runner}"
        output = ''
        line   = ''

        thread = Thread.new do
          #puts ">> runner is: #{runner}"
          while true do
            char = runner.readpartial 1
            puts "char: #{char}"

            sleep 0.1
          end
        end

        thread.join
      end
    end
  end
end

