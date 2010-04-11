require 'rake'
require 'platform'
require 'sprout/log'
require 'sprout/user'
require 'sprout/process_runner'

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

