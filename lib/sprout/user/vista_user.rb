
module Sprout::User

  class VistaUser < WinUser

    def home
      profile = env_userprofile
      if(profile)
        return profile
      end
      return super
    end

    def env_userprofile
      ENV['USERPROFILE']
    end
  end
end

