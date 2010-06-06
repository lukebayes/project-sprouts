
module Sprout::System

  class OSXSystem < UnixSystem
    LIBRARY = 'Library'

    def library
      lib = File.join(home, LIBRARY)
      if(File.exists?(lib))
        return lib
      else
        return super
      end
    end

    def format_application_name(name)
      return name.capitalize
    end

    def can_execute? platform
      [:mac, :osx, :macosx, :darwin].include?(platform) || super
#      platform == :mac || platform == :osx || platform == :macosx || platform == :darwin || super
    end

  end
end

