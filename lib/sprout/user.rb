require 'sprout/user/base_user'
require 'sprout/user/unix_user'
require 'sprout/user/java_user'
require 'sprout/user/osx_user'
require 'sprout/user/win_user'
require 'sprout/user/win_nix_user'
require 'sprout/user/vista_user'

module Sprout

  module User

    # This is the factory that one should
    # generally be used to create new, concrete
    # User objects.
    #
    # A typical example follows:
    #
    #     user = User.create
    #     Dir.chdir user.home
    #     user.execute "pwd" # /home/yourusername
    #
    def self.create
      p = Sprout::Platform.new
      return VistaUser.new  if p.vista?
      return WinNixUser.new if p.windows_nix?
      return WinUser.new    if p.windows?
      return JavaUser.new   if p.java?
      return OSXUser.new    if p.mac?
      return UnixUser.new 
    end

  end
end

