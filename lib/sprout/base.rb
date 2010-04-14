require 'rake'

# Core, Crossplatform support:
require 'sprout/log'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'

module Sprout

  class UsageError < StandardError #:nodoc
  end

  class SproutError < StandardError #:nodoc:
  end

  class ExecutionError < StandardError # :nodoc:
  end

  class Base
  end
end

