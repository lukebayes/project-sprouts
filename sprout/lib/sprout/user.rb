require 'platform'
require 'sprout/log'
require 'sprout/process_runner'

module Sprout

  class ExecutionError < StandardError # :nodoc:
  end

  # The User class provides a single and consistent interface to User based paths
  # and features so that Sprout implementation code doesn't need to be concerned
  # with which Operating system it is running on.
  #
  class User
    @@user = nil

    # Retrieve a user instance that represents the currently logged in user on this system.
    def User.new(os=nil, impl=nil)
        if(os.nil? && impl.nil? && @@user)
          return @@user
        end
        if(os.nil?)
          os = Platform::OS
        end
        if(impl.nil?)
          impl = Platform::IMPL
        end
        if(os == :win32 && impl == :vista)
          @@user = VistaUser.new
        elsif(os == :win32 && impl == :cygwin)
          @@user = CygwinUser.new
        elsif(os == :win32)
          @@user = WinUser.new
        elsif(os == :unix && impl == :macosx)
          @@user = OSXUser.new
#        elsif(os == :unix && impl == :linux)
#          @@user = UnixUser.new
        else
          @@user = UnixUser.new
        end
    end

    def User.user=(user) # :nodoc:
      @@user = user
    end

    def User.home=(path) # :nodoc:
      User.new().home = path
    end
    
    def User.is_a?(type)
      User.new().is_a?(type)
    end

    # Pass an executable or binary file name and find out if that file exists in the system
    # path or not
    def User.in_path?(executable)
      User.new().in_path?(executable)
    end
    
    # Retrieve the full path to an executable that exists in the user path
    def User.get_exe_path(executable)
      return User.new().get_exe_path(executable)
    end

    # Return the home path for the currently logged in user. If the user name is lbayes, this should be:
    #
    # Windows XP::  C:\Documents And Settings\lbayes
    # Cygwin::  /cygdrive/c/Documents And Settings/lbayes 
    # OS X::  /Users/lbayes
    # Linux::   ~/
    def User.home
      User.new().home
    end

    # Returns the home path for a named application based on the currently logged in user and operating system.
    # If the user name is lbayes and the application name is Sprouts, this path will be:
    #
    # Windows XP::  C:\Documents And Settings\lbayes\Local Settings\Application Data\Sprouts
    # Cygwin::  /cygdrive/c/Documents And Settings/Local Settings/Application Data/Sprouts
    # OS X::  /Users/lbayes/Library/Sprouts
    # Linux::   ~/.sprouts
    def User.application_home(name)
      return User.new().application_home(name)
    end

    # Returns the library path on the current system. This is the general path where all applications should
    # store configuration or session data.
    #
    # Windows XP::   C:\Documents And Settings\lbayes\Local Settings\Application Data
    # Cygwin::  /cygdrive/c/Documents And Settings/lbayes/Local Settings/Application Data 
    # OS X::   /Users/lbayes/Library
    # Linux::   ~/
    def User.library
      return User.new().library
    end

    # Execute a named tool sprout. The full sprout name should be provided to the tool parameter, and
    # a string of shell parameters that will be sent to the tool itself.
    def User.execute(tool, options='')
      return User.new().execute(tool, options)
    end
    
    def User.execute_silent(tool, options='')
      return User.new().execute_silent(tool, options)
    end

    # Execute a named tool sprout as a new thread and return that thread
    def User.execute_thread(tool, options='')
      if(Log.debug)
         return ThreadMock.new
      else
         return User.new().execute_thread(tool, options)
      end
    end

    # Clean a path string in such a way that works for each platform. For example, Windows doesn't like
    # it when we backslash to escape spaces in a path because that is the character they use as a delimiter.
    # And OS X doesn't really like it when we wrap paths in quotes.
    def User.clean_path(path)
      return User.new().clean_path(path)
    end

  end

  #############################
  # UnixUser class
  class UnixUser # :nodoc:

    def initialize
      setup_user
      @home = nil
    end
    
    def setup_user
    end

    def home=(path)
      @home = path
    end

    def home
      if(@home)
        return @home
      end
      
      # Original implementation:
      #["HOME", "USERPROFILE"].each do |homekey|
      # Change submitted by Michael Fleet (dissinovate)
      # Does this work for everyone on Windows?
      ["USERPROFILE", "HOME"].each do |homekey|
        return @home = ENV[homekey] if ENV[homekey]
      end

      if ENV["HOMEDRIVE"] && ENV["HOMEPATH"]
        return @home = "#{ENV["HOMEDRIVE"]}:#{ENV["HOMEPATH"]}"
      end

      begin
        return @home = File.expand_path("~")
      rescue StandardError => e
        if File::ALT_SEPARATOR
          return @home = "C:\\"
        else
          return @home = "/"
        end
      end
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

    def get_process_runner(command)
      return ProcessRunner.new(command)
    end

    # Creates a new process, executes the command
    # and returns the result and throws if the process
    # writes to stderr
    def execute(tool, options='')
      Log.puts(">> Execute: #{File.basename(tool)} #{options}")
      tool = clean_path(tool)
      runner = get_process_runner("#{tool} #{options}")

      error = runner.read_err
      result = runner.read

      if(result.size > 0)
        Log.puts result
      end

      if(error.size > 0)
        raise ExecutionError.new("[ERROR] #{error}")
      end
    end

    # Creates and returns the process without
    # attempting to read or write to the stream.
    # This is useful for interacting with
    # long-lived CLI processes like FCSH or FDB.
    def execute_silent(tool, options='')
      tool = clean_path(tool)
      return get_process_runner("#{tool} #{options}")
    end

    def execute_thread(tool, options='')
      return Thread.new do
        execute(tool, options)
      end
    end

    def clean_path(path)
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
  end

  class OSXUser < UnixUser # :nodoc:
    @@LIBRARY = 'Library'

    def library
      lib = File.join(home, @@LIBRARY)
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

  class WinUser < UnixUser # :nodoc:
    @@LOCAL_SETTINGS = "Local\ Settings"
    @@APPLICATION_DATA = "Application\ Data"

    def initialize
      super
      @home = nil
    end
    
    def setup_user
    end

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
      application_data = File.join(home, @@LOCAL_SETTINGS, @@APPLICATION_DATA)
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

  class CygwinUser < WinUser # :nodoc:

    def initialize
      super
      @home = nil
      @win_home = nil
      @win_home_cyg_path = nil
    end
    
    def setup_user
    end

    def clean_path(path)
      if(path.index(' '))
        return %{'#{path}'}
      end
      return path
    end

    def win_home
      if(@win_home.nil?)
        @win_home = ENV['HOMEDRIVE'] + ENV['HOMEPATH']
      end
      return @win_home
    end

    def home
      if(@home.nil?)
        path = win_home.split('\\').join("/")
        path = path.split(":").join("")
        parts = path.split("/")
        path = parts.shift().downcase + "/" + parts.join("/")
        @home = "/cygdrive/" + path
      end
    return @home
    end

  end

  class VistaUser < WinUser # :nodoc:
    def home
      profile = ENV['USERPROFILE']
      if(profile)
        return profile
      end
      return super
    end
  end

  class ThreadMock # :nodoc:
    def alive?
      return false
    end
  end
end
