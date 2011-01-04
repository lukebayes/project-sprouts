module Sprout

  class CommandLine < Sprout::Executable::Base

    ##
    # Get the version of the Sprout gem
    add_param :version, Boolean, :default => false, :hidden_value => true

    add_param_alias :v, :version

    ##
    # @return [IO] default $stdout, Replace value in test context.
    attr_accessor :logger

    def initialize
      super
      @logger = $stdout
    end

    def parse! options
      if options.empty?
        handle_parse_error Sprout::Errors::UsageError.new("At least one parameter is required.")
      end
      super
    end

    def execute
      if version
        logger.puts "sprout #{Sprout::VERSION::STRING}"
      end
    end
  end
end
