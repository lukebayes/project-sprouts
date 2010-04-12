
module Sprout

  # Determine what environment we're in so that we
  # can play nice with libraries, processes, executables, etc.
  module Platform

    def ruby_platform
      RUBY_PLATFORM
    end

    def windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ ruby_platform) != nil
    end

    def windows_nix?
      (/cygwin|mingw|bccwin/ =~ ruby_platform) != nil
    end

    def mac?
      (/darwin/ =~ ruby_platform) != nil
    end

    def unix?
      !windows?
    end

    def linux?
      unix? and not mac?
    end
  end
end

