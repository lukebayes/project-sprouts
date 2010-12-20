
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
          action = name.to_s
          action = "y" if name == :confirm # Convert affirmation
          action << " #{params.join(' ')}" unless params.nil?
          action_stack << action
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
        runner = super
        execute_actions runner
        handle_user_session runner
        Process.wait runner.pid
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
        action_stack.each do |action|
          if wait_for_prompt runner
            Sprout::Log.puts action
            execute_action runner, action
          end
        end
      end

      def execute_action runner, action
        runner.puts action.strip
      end

      def handle_user_session runner
        while !runner.r.eof?
          if wait_for_prompt runner
            input = $stdin.gets.chomp!
            execute_action runner, input
          end
        end
      end

      def wait_for_prompt runner, expected_prompt=nil
        ##
        # TODO: This should also check for a variety of prompts...
        expected_prompt = expected_prompt || prompt
        line = ''

        while runner.alive? do
          Sprout::Log.flush
          return false if runner.r.eof?
          char = runner.readpartial 1
          line << char
          if char == "\n"
            line = ''
          end
          Sprout::Log.printf char
          return true if line.match expected_prompt
        end
      end

    end
  end
end

