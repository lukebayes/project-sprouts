require 'sprout/system/base_system'
require 'sprout/system/unix_system'
require 'sprout/system/java_system'
require 'sprout/system/osx_system'
require 'sprout/system/win_system'
require 'sprout/system/win_nix_system'
require 'sprout/system/vista_system'

module Sprout

  module System

    # This is the factory that one should
    # generally be used to create new, concrete
    # System objects.
    #
    # A typical example follows:
    #
    #     system = System.create
    #     Dir.chdir system.home
    #     system.execute "pwd" # /home/yourusername
    #
    def self.create
      p = Sprout::Platform.new
      return VistaSystem.new  if p.vista?
      return WinNixSystem.new if p.windows_nix?
      return WinSystem.new    if p.windows?
      return JavaSystem.new   if p.java?
      return OSXSystem.new    if p.mac?
      return UnixSystem.new 
    end

  end
end

