require 'rake'

# Core, Crossplatform support:
require 'sprout/log'
require 'sprout/exceptions'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'
require 'sprout/file_target'
require 'sprout/remote_file_target'

# External Packager support:
require 'sprout/specification'
require 'sprout/tool'

module Sprout

  class Base; end
end

