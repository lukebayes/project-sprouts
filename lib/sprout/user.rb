require 'sprout/user/unix'
require 'sprout/user/java'
require 'sprout/user/osx'
require 'sprout/user/win'
require 'sprout/user/win_nix'
require 'sprout/user/vista'

module Sprout

  module User

    def self.create
      p = platform
      return Vista.new  if p.vista?
      return WinNix.new if p.windows_nix?
      return Win.new    if p.windows?
      return Java.new   if p.java?
      return OSX.new    if p.mac?
      return Unix.new 
    end

    def self.platform
      @platform ||= Platform.new
    end

  end
end

