
module Sprout::System

  class VistaSystem < WinSystem

    def home
      return env_userprofile unless env_userprofile.nil?
      return super
    end

    def env_userprofile
      ENV['USERPROFILE']
    end
  end
end

