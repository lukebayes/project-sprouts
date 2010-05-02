
module Sprout::User

  # The default Windows user.
  # This is the user type for all
  # major versions and flavors of Windows
  # (except Cygwin and Mingw).
  class WinUser < BaseUser
    LOCAL_SETTINGS = "Local\ Settings"
    APPLICATION_DATA = "Application\ Data"

    def home
      usr = super
      if(usr.index "My Documents")
        usr = File.dirname(usr)
      end
      return usr
    end

    def get_paths
      return ENV['PATH'].split(';')
    end

    def library
      # For some reason, my homepath returns inside 'My Documents'...
      application_data = File.join(home, LOCAL_SETTINGS, APPLICATION_DATA)
      if(File.exists?(application_data))
        return application_data
      else
        return super
      end
    end

    def clean_path(path)
      path = path.split('/').join("\\")
      if(path.index(' '))
        return %{"#{path}"}
      end
      return path
    end

    def format_application_name(name)
      return name.capitalize
    end
  end
end

