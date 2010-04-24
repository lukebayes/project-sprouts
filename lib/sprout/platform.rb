
module Sprout

  ##
  # Determine what environment we're in so that we
  # can play nice with libraries, processes, executables, etc.
  #
  class Platform

    ##
    # Returns +true+ if the current platform is some flavor of Windows.
    #
    def windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx|vista/ =~ ruby_platform) != nil
    end

    ##
    # Returns +true+ if the current platform is Vista.
    #
    def vista?
      (/vista/ =~ ruby_platform) != nil
    end

    ##
    # Returns +true+ if the current platform is some flavor of Unix on
    # Windows. Recognized nix-ish systems are: Cygwin, Mingw and BCCWin.
    #
    def windows_nix?
      (/cygwin|mingw|bccwin/ =~ ruby_platform) != nil
    end

    ##
    # Returns +true+ if the current platform is some flash of OS X.
    #
    def mac?
      (/darwin/ =~ ruby_platform) != nil
    end

    ##
    # Returns +true+ if the current platform is not +windows?+ or +java?+.
    #
    def unix?
      not windows? and not java?
    end

    ##
    # Returns +true+ if the current platform is +unix?+ and not +mac?+.
    #
    def linux?
      unix? and not mac?
    end

    ##
    # Returns +true+ if the current platform is running in the JVM (JRuby).
    #
    def java?
      (/java/ =~ ruby_platform) != nil
    end

    ##
    # Instance wrapper for the global Ruby Constant, +RUBY_PLATFORM+.
    #
    # wrapping this global allows for much easier testing and environment simulation.
    #
    def ruby_platform
      RUBY_PLATFORM
    end

  end
end

