
module Sprout::System

  class UnixSystem < BaseSystem

    def clean_path path
      return if path.nil?
      if(path.include? '../')
        path = File.expand_path path
      end

      if(path.index(' '))
        return path.split(' ').join('\ ')
      end
      return path
    end

    def execute(tool, options='')
      attempt_to_repair_executable tool
      super(tool, options)
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
      [:unix, :linux].include?(platform) || super
    end

    ##
    # Repair Windows Line endings
    # found in non-windows executables
    # (Flex SDK is regularly published
    # with broken CRLFs)
    #
    # +path+ String path to the executable file.
    #
    def attempt_to_repair_executable path
      repair_executable(path) if should_repair_executable(path)
    end

    def repair_executable path
      content = File.read(path)
      if(content.match(/\r\n/))
        Sprout::Log.puts "[WARNING] Sprouts is about to replace invalid Windows line endings on an executable at: (#{path})"
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
    # Will this corrupt binaries? Yes... Yes. it. will.
    def should_repair_executable path
      return (File.exists?(path) && !File.directory?(path) && File.read(path).match(/^\#\!\/bin\/sh/))
    end

  end
end

