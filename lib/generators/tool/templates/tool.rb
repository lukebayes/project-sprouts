require 'sprout'

class <%= input.camel_case %>

  NAME = '<%= input.snake_case %>'

  module VERSION
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    STRING = "#{MAJOR}.#{MINOR}.#{TINY}"
  end

  Sprout::Specification.new do |s|
    s.name    = <%= input.camel_case %>::NAME
    s.version = <%= input.camel_case %>::VERSION::STRING

    # Create an independent remote_file_target for each
    # platform that must be supported independently.
    #
    # If the archive includes support for all platforms (:windows, :osx, :unix)
    # then set platform = :universal
    #
    s.add_remote_file_target do |t|
      t.platform = :universal
      t.archive_type = :zip
      t.url          = "<%= url %>"
      t.md5          = "<%= md5 %>"

      # List all executables with their relative path within the
      # unpacked archive here:
      t.add_executable :<%= exe %>, "bin/<%= exe %>"
    end

  end
end


