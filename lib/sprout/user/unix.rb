
module Sprout::User

  class Unix

    attr_accessor :home

    def initialize
      setup_user
      @home = nil
    end
    
    def setup_user
    end

    def home
      @home ||= find_home
    end

    def get_exe_path(executable)
      paths = get_paths
      file = nil
      paths.each do |path|
        file = File.join(path, executable)
        if(File.exists?(file))
          return file
        end
      end
      return nil
    end

    def in_path?(executable)
      return !get_exe_path(executable).nil?
    end

    def get_paths
      return ENV['PATH'].split(':')
    end

    def library
      return home
    end

    def platform
      if(Platform::OS == :win32)
        return :win32
      elsif(Platform::IMPL == :macosx)
        return :macosx
      else
        return Platform::IMPL
      end
    end

    def get_process_runner(*command)
      runner = ProcessRunner.new
      runner.execute_open4 *command
      return runner
    end

    # Creates a new process, executes the command
    # and returns the result and throws if the process
    # writes to stderr
    def execute(tool, options='')
      Log.puts(">> Execute: #{File.basename(tool)} #{options}")
      tool   = clean_path(tool)
      runner = get_process_runner(tool, options)
      error  = runner.read_err
      result = runner.read

      if(result.size > 0)
        Log.puts result
      end

      if(error.size > 0)
        raise ExecutionError.new("[ERROR] #{error}")
      end

      result || error
    end

    # Creates and returns the process without
    # attempting to read or write to the stream.
    # This is useful for interacting with
    # long-lived CLI processes like FCSH or FDB.
    def execute_silent(tool, options='')
      tool = clean_path(tool)
      return get_process_runner(tool, options)
    end

    def execute_thread(tool, options='')
      return Thread.new do
        execute(tool, options)
      end
    end

    # Repair Windows Line endings
    # found in non-windows executables
    # (Flex SDK is regularly published
    # with broken CRLFs)
    def repair_executable(path)
      return unless should_repair_executable(path)

      content = File.read(path)
      if(content.match(/\r\n/))
        content.gsub!(/\r\n/, "\n")
        File.open(path, 'w+') do |f|
          f.write content
        end
      end
    end

    def should_repair_executable(path)
      return (File.exists?(path) && !File.directory?(path) && File.read(path).match(/^\#\!/))
    end

    def clean_path(path)
      repair_executable path

      if(path.index(' '))
        # Changed 2/26/2008 in attempt to support 
        # ToolTask.PathsParam s that have spaces in the values
        return path.split(' ').join('\ ')
#        return %{'#{path}'}
      end
      return path
    end

    def application_home(name)
      return File.join(library, format_application_name(name.to_s));
    end

    def format_application_name(name)
      if(name.index('.') != 0)
        name = '.' + name
      end
      return name.split(" ").join("_").downcase
    end

    protected

    def env_homedrive
      ENV['HOMEDRIVE']
    end

    def env_homepath
      ENV['HOMEPATH']
    end

    def env_homedrive_and_homepath
      drive = env_homedrive
      path = env_homepath
      "#{drive}:#{path}" if drive && path
    end

    def env_userprofile
      ENV['USERPROFILE']
    end

    def env_home
      ENV['HOME']
    end

    def tilde_home
      File.expand_path("~")
    end

    def alt_separator?
      File::ALT_SEPARATOR
    end

    def worst_case_home
      return "C:\\" if alt_separator?
      return "/"
    end

    def find_home
      [:env_userprofile, :env_home, :env_homedrive_and_homepath].each do |key|
        value = self.send(key)
        return value unless value.nil?
      end

      begin
        return tilde_home
      rescue StandardError => e
        worst_case_home
      end
    end
  end
end

