
module Sprout::System

  # The default Windows system.
  # This is the system type for all
  # major versions and flavors of Windows
  # (except Cygwin and Mingw).
  class WinSystem < BaseSystem
    LOCAL_SETTINGS = "Local\ Settings"
    APPLICATION_DATA = "Application\ Data"

    def home
      path = super
      if(path.include? "My Documents")
        path = File.dirname(path)
      end
      return path
    end

    def get_paths
      return env_path.split(';')
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

    def can_execute? platform
      [:windows, :win32].include?(platform) || super
    end

    protected

    ##
    # Gets the process runner and calls
    # platform-specific execute method
    def get_and_execute_process_runner tool, options=nil
      runner = get_process_runner
      runner.execute_win32 tool, options
      runner
    end

    private

    def env_path
      ENV['PATH']
    end

  end
end

