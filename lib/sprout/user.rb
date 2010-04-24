require 'sprout/user/base'
require 'sprout/user/unix'
require 'sprout/user/java'
require 'sprout/user/osx'
require 'sprout/user/win'
require 'sprout/user/win_nix'
require 'sprout/user/vista'

module Sprout

  module User

    # This is the factory that one should
    # generally use to create new, concrete
    # User objects.
    #
    # A typical example follows:
    #
    #     user = User.create
    #     Dir.chdir user.home
    #     user.execute "pwd" # /home/yourusername
    #
    def self.create
      p = Platform.new
      return Vista.new  if p.vista?
      return WinNix.new if p.windows_nix?
      return Win.new    if p.windows?
      return Java.new   if p.java?
      return OSX.new    if p.mac?
      return Unix.new 
    end

  end
end

