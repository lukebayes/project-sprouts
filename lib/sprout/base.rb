require 'rake'

# Core, Crossplatform support:
require 'sprout/log'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'

module Sprout

  # A general Sprout Error was encountered.
  class SproutError < StandardError; end

  # An unexpected input was used or method was called.
  class UsageError < SproutError; end

  # Sprouts was unable to accomplish the request.
  class ExecutionError < SproutError; end

  class Base; end
end

