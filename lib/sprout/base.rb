require 'rake'

# Core, Process and Platform support:
require 'sprout/concern'
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'
require 'sprout/file_target'
require 'sprout/remote_file_target'

# External Packaging and distribution support:
require 'sprout/specification'
require 'sprout/tool'

module Sprout

  module Base
    extend Concern

    module ClassMethods

      def get_executable file_target, gem_name, gem_version=nil
        puts "exe: #{exe}"
      end
    end

  end
end

