
module Sprout::User

  class UnixUser < BaseUser

    def clean_path path
      if(path.include? '../')
        path = File.expand_path path
      end
      #repair_executable path

      if(path.index(' '))
        return path.split(' ').join('\ ')
      end
      return path
    end

    ##
    # Ensure Application +name+ String begins with a dot (.), and does
    # not include spaces.
    #
    def format_application_name(name)
      if(name.index('.') != 0)
        name = '.' + name
      end
      return name.split(" ").join("_").downcase
    end

    def can_execute? platform
      platform == :unix || platform == :linux || super
    end

    ##
    # Repair Windows Line endings
    # found in non-windows executables
    # (Flex SDK is regularly published
    # with broken CRLFs)
    #
    # +path+ String path to the executable file.
    #
    def repair_executable path
      return unless should_repair_executable(path)

      content = File.read(path)
      if(content.match(/\r\n/))
        content.gsub!(/\r\n/, "\n")
        File.open(path, 'w+') do |f|
          f.write content
        end
      end
    end

    ##
    # Determine if we should call +repair_executable+
    # for the file at the provided +path+ String.
    #
    def should_repair_executable path
      return (File.exists?(path) && !File.directory?(path) && File.read(path).match(/^\#\!/))
    end

  end
end

