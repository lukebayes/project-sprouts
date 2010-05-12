
module Sprout

  ##
  # A module, below which, all errors should be found.
  #
  module Errors

    ##
    # A general Sprout Error was encountered.
    class SproutError < StandardError; end

    ##
    # An error in the Tool was encountered
    class ToolError < SproutError; end



    ##
    # There was a problem with the requested
    # unpack operation.
    class ArchiveUnpackerError < SproutError; end

    ##
    # The unpacked file was already found in the destination
    # directory and the ArchiveUnpacker was not asked to clobber.
    class DestinationExistsError < ArchiveUnpackerError; end

    ##
    # Sprouts was unable to accomplish the request.
    class ExecutionError < SproutError; end

    ##
    # Error when registering executables.
    class ExecutableRegistrationError < ToolError; end

    ##
    # Could not find requested Executable
    class MissingExecutableError < ToolError; end

    ##
    # There was an error in ProcessRunner
    class ProcessRunnerError < SproutError; end

    ##
    # Error on remote file download
    class RemoteFileLoaderError < StandardError; end

    ##
    # An unexpected input was used or method was called.
    class UsageError < SproutError; end

    ##
    # Can't figure out how to unpack this type of file.
    # Try again with a .zip, .tgz, or .tar.gz
    class UnknownArchiveType < SproutError; end

    ##
    # Error when a feature is not in a valid state
    class ValidationError < SproutError; end

    ##
    # Could not meet the requested version requirement.
    class VersionRequirementNotMetError < SproutError; end

  end
end

