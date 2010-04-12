
module Sprout

  # Determine what environment we're in so that we
  # can play nice with libraries, processes, executables, etc.
  class Platform

    def ruby_platform
      RUBY_PLATFORM
    end

    def windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx|vista/ =~ ruby_platform) != nil
    end

    def vista?
      (/vista/ =~ ruby_platform) != nil
    end

    def windows_nix?
      (/cygwin|mingw|bccwin/ =~ ruby_platform) != nil
    end

    def mac?
      (/darwin/ =~ ruby_platform) != nil
    end

    def unix?
      not windows? and not java?
    end

    def linux?
      unix? and not mac?
    end

    def java?
      (/java/ =~ ruby_platform) != nil
    end
  end
end

