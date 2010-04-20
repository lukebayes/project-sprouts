require 'rake'

# Core, Crossplatform support:
require 'sprout/log'
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

  # A general Sprout Error was encountered.
  class SproutError < StandardError; end

  # An unexpected input was used or method was called.
  class UsageError < SproutError; end

  # Sprouts was unable to accomplish the request.
  class ExecutionError < SproutError; end

  # There was a problem with the requested
  # unpack operation.
  class ArchiveUnpackerError < SproutError; end

  # Can't figure out how to unpack this type of file.
  # Try again with a .zip, .tgz, or .tar.gz
  class UnknownArchiveType < SproutError; end

  # The unpacked file was already found in the destination
  # directory and the ArchiveUnpacker was not asked to clobber.
  class DestinationExistsError < ArchiveUnpackerError; end

  class Base; end
end

