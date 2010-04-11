require 'rake'
require 'platform'
require 'sprout/log'
require 'sprout/process_runner'
require 'sprout/user'

module Sprout

  class UsageError < StandardError #:nodoc
  end

  class SproutError < StandardError #:nodoc:
  end

  class ExecutionError < StandardError # :nodoc:
  end

  class Base

    def initialize
    end

  end
end

