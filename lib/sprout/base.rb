require 'rake'

# Core, Crossplatform support:
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'
require 'sprout/file_target'

# External Packager support:
require 'sprout/library'
require 'sprout/tool'

module Sprout

  class Base; end
end

