
module Sprout::User

  class OSXUser < UnixUser
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

  end
end

