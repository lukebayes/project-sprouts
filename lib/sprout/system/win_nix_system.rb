
module Sprout::System

  # The concrete system for Cygwin and Mingw
  # We can't quite treat these users like
  # a typical *nix system, but we can't quite
  # treat them like Windows users either.
  #
  # One great thing about these users,
  # is that we get to use real processes,
  # rather than the broken processes that
  # windows normally offers.
  class WinNixSystem < WinSystem

    def win_home
      @win_home ||= ENV['HOMEDRIVE'] + ENV['HOMEPATH']
    end

    def home
      @home ||= win_nix_home
    end

    def win_nix_home
      path  = win_home.split('\\').join("/")
      return path if File.exists?(path)

      parts = path.split("/")
      path  = parts.shift().downcase + "/" + parts.join("/")
      path  = path.split(":").join("")
      "/cygdrive/" + path
    end

  end
end

