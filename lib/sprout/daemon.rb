
module Sprout

  ##
  # The Sprout::Daemon module exposes the Domain Specific Language
  # provided by the Sprout::Executable module, but with
  # enhancements (and modifications) to support long-lived processes
  # (like FDB and FCSH).
  #
  # NOTE: Any class that includes Sprout::Daemon should first include 
  # Sprout::Executable. This is an admittedly smelly constraint, but it works
  # for now.
  #
  #   class Foo
  #     include Sprout::Executable
  #     include Sprout::Daemon
  #
  #     ##
  #     # Keep in mind that we're still working
  #     # with Executable, so add_param is available
  #     # for the initialization of the process.
  #     add_param :input, File
  #
  #     ##
  #     # Expose the do_something action after
  #     # the process is started.
  #     add_action :do_something
  #
  #     ##
  #     # Expose the do_something_else action after
  #     # the process is started.
  #     add_action :do_something_else
  #   end
  #
  # You can also create a globally-accessible rake task to expose
  # your new Daemon instance to Rake by creating a method like the following:
  #
  #   def foo *args, &block
  #     foo_tool = Foo.new
  #     foo_tool.to_rake *args, &block
  #   end
  #
  # Note: The aforementioned rake helper is usually written at the bottom of 
  # the class file that is referenced.
  # 
  # The aforementioned Rake task could be used like:
  #
  #   foo :bar do |t|
  #     t.do_something
  #     t.do_something_else
  #   end
  #
  # @see: Sprout::Daemon::ClassMethods
  # @see: Sprout::Daemon::InstanceMethods
  #
  class Daemon < Executable::Base

    class << self

      ##
      # Add an action that can be called while
      # the long-lived process is active.
      #
      # This method should raise a Sprout::Errors::UsageError
      # if the provided action name is already defined for 
      # the provided instance.
      def add_action name, arguments=nil, options=nil
        options ||= {}
        options[:name] = name
        options[:arguments] = arguments
        create_action_method options
      end

      ##
      # Create an (often shorter) alias to another
      # action name.
      def add_action_alias alias_name, source_name
        define_method(alias_name) do |*params|
          self.send(source_name, params)
        end
      end

      private

      ##
      # Actually create the method for a provided
      # action.
      #
      # This method should explode if the method name
      # already exists.
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
      # TODO: Raise an exception if the name is 
      # already taken?
      def accessor_can_be_defined_at name
      end

    end


    ##
    # The prompt expression for this daemon process.
    #
    # When executing a series of commands, the
    # wrapper will wait until it matches this expression
    # on stdout before continuing the series.
    #
    # For FDB, this value is set like:
    #
    #   set :prompt, /^\(fdb\) /
    #
    # Most processes can trigger a variety of different
    # prompts, these can be expressed here using the | (or) operator.
    #
    # FDB actually uses the following:
    #
    #   set :prompt, /^\(fdb\) |\(y or n\) /
    #
    attr_accessor :prompt

    ##
    # This is the array of actions that have
    # been provided at the class level to this instance.
    attr_reader :action_stack

    def initialize
      super
      @action_stack = []
    end

    ##
    # Execute the Daemon executable, followed
    # by the collection of stored actions in 
    # the order they were called.
    #
    # If none of the stored actions result in
    # terminating the process, the underlying
    # daemon will be connected to the terminal
    # for user (manual) input.
    def execute
      runner = super
      execute_actions runner
      handle_user_session runner
      Process.wait runner.pid
    end

    protected

    ##
    # This is the override of the underlying
    # Sprout::Executable template method so that we
    # create a 'task' instead of a 'file' task.
    def create_outer_task *args
      task *args do
        execute
      end
    end

    ##
    # This is the override of the underlying
    # Sprout::Executable template method so that we
    # are NOT added to the CLEAN collection.
    # (Work performed in the Executable)
    def update_rake_task_name_from_args *args
      self.rake_task_name = parse_rake_task_arg args.last
    end

    ##
    # This is the override of the underlying
    # Sprout::Executable template method so that we
    # create the process in a thread 
    # in order to read and write to it.
    def system_execute binary, params
      Sprout.current_system.execute_thread binary, params
    end

    private

    ##
    # Execute the collection of provided actions.
    def execute_actions runner
      action_stack.each do |action|
        if wait_for_prompt runner
          Sprout::Log.puts action
          execute_action runner, action
        end
      end
    end

    ##
    # Execute a single action.
    def execute_action runner, action
      runner.puts action.strip
    end

    ##
    # Expose the running process to manual
    # input on the terminal, and write stdout
    # back to the user.
    def handle_user_session runner
      while !runner.r.eof?
        if wait_for_prompt runner
          input = $stdin.gets.chomp!
          execute_action runner, input
        end
      end
    end

    ##
    # Wait for the underlying process to present
    # an input prompt, so that another action
    # can be submitted, or user input can be
    # collected.
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

