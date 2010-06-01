
module Sprout

  ##
  # A module, below which, all errors should be found.
  #
  module Errors

    ##
    # A general Sprout Error was encountered.
    class SproutError < StandardError; end

    ##
    # An error in the Executable was encountered.
    class ExecutableError < SproutError; end

    ##
    # An error in a Generator was encountered.
    class GeneratorError < SproutError; end

    ##
    # Unable to find the expected template for a Generator.
    class MissingGeneratorError < GeneratorError; end

    ##
    # Unable to find the expected template for a Generator.
    class MissingTemplateError < GeneratorError; end

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
    # Requested parameter or accessor already exists.
    class DuplicateMemberError < ExecutableError; end

    ##
    # Error when registering executables.
    class ExecutableRegistrationError < ExecutableError; end

    ##
    # Could not find requested ExecutableTarget
    class MissingExecutableError < ExecutableError; end

    ##
    # Required argument was not provided
    class MissingArgumentError < ExecutableError; end

    ##
    # An argument was provided that was not valid
    class InvalidArgumentError < ExecutableError; end

    ##
    # There was an error in ProcessRunner
    class ProcessRunnerError < SproutError; end

    ##
    # There was a problem requiring a requested file
    class LoadError < SproutError; end

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

