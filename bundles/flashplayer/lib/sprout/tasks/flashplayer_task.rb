=begin
Copyright (c) 2007 Pattern Park

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

module Sprout
  
  class FlashPlayerError < StandardError #:nodoc:
  end
  
  # This exception will be raised when the FlashPlayerTask has encountered
  # a test_result_pre_delimiter and subsequently a well-formatted JUnit
  # XML result test failure
  class AssertionFailure < StandardError #:nodoc:
  end
  
  # The FlashPlayerTask will download, unpack, configure and launch the debug 
  # Flash Player for OS X, Windows and Linux.
  # 
  # Simply send the rake task the +swf+ you'd like to launch either indirectly as a 
  # rake dependency or directly as the +swf+ property of this task.
  #
  #   flashplayer :run => 'bin/SomeProject.swf'
  #
  # Or you could:
  #
  #   flashplayer :run do |t|
  #     t.swf = 'bin/SomeProject.swf'
  #   end
  #
  class FlashPlayerTask < Rake::Task
    # This is the opening prelude to a collection of test results. When the
    # task encounters this string in the trace output log file, it will begin
    # collecting trace statements with the expectation that the following
    # strings will be well-formatted XML data matching what JUnit emits for 
    # Cruise Control.
    #
    # See the lib/asunit3/asunit.framework.XMLResultPrinter for more information.
    @@test_result_pre_delimiter = '<XMLResultPrinter>'

    # This is the closing string that will indicate the end of test result XML data
    @@test_result_post_delimiter = '</XMLResultPrinter>'

    @@home = nil
    @@trust = nil

    def initialize(task_name, app)
      super(task_name, app)
      @default_gem_name = 'sprout-flashplayer-tool'
      @default_gem_version = '10.22.0'
      @default_result_file = 'AsUnitResults.xml'
      @inside_test_result = false
    end

    def self.define_task(args, &block)
      t = super
      yield t if block_given?
      t.define
    end
    
    # Local system path to the Flash Player Trust file
    def FlashPlayerTask.trust
      if(@@trust)
        return @@trust
      end
      @@trust = File.join(FlashPlayerTask.home, '#Security', 'FlashPlayerTrust', 'sprout.cfg')
      return @@trust
    end

    # Local system path to where the Flash Player stores trace output logs and trust files
    def FlashPlayerTask.home
      if(@@home)
        return @@home
      end

      FlashPlayerTask.home_paths.each do |path|
        if(File.exists?(path))
          return @@home = path
        end
      end

      if(@@home.nil?)
        raise FlashPlayerError.new('FlashPlayer unable to find home folder for your platform')
      end
      return @@home
    end

    # Collection of the potential locations of the Flash Player Home
    # For each supported Platform, the first existing location
    # will be used.
    def FlashPlayerTask.home_paths
      return [File.join(User.library, 'Preferences', 'Macromedia', 'Flash Player'),
              File.join(User.library, 'Application Support', 'Macromedia'),
              File.join(User.home, 'Application Data', 'Macromedia', 'Flash Player'),
              File.join(User.home, 'AppData', 'Roaming', 'Macromedia', 'Flash Player'),
              File.join(User.home, '.macromedia', 'Flash_Player')]
    end

    # The swf parameter can be set explicitly in the block sent to this task as in:
    #   
    #   flashplayer :run do |t|
    #     t.swf = 'bin/SomeProject.swf'
    #   end
    #
    # Or it can be set implicitly as a rake prerequisite as follows:
    #
    #   flashplayer :run => 'bin/SomeProject' do |t|
    #   end
    #
    def swf=(swf)
      @swf = swf
    end

    def swf
      @swf ||= nil
      if(@swf.nil?)
        prerequisites.each do |req|
          if(req.index('.swf'))
            @swf = req.to_s
            break
          end
        end
      end
      return @swf
    end

    # By default, the Flash Player should be given focus after being launched. Unfortunately,
    # this doesn't work properly on OS X, so we needed to do some hackery in order to make it
    # happen. This in turn can lead to multiple instances of the Player being instantiated.
    # In the case of running a test harness, this is absolutely not desirable, so we had
    # expose a parameter that allows us to prevent auto-focus of the player.
    #
    # This feature is deprecated in current versions of the FlashPlayerTask
    def do_not_focus=(focus)
      @do_not_focus = focus
      puts "[WARNING] Thanks to fixes in the FlashPlayer task, do_not_focus is deprecated and no longer needs to be used"
    end
    
    def do_not_focus
      @do_not_focus ||= nil
    end

    # The gem version of the sprout-flashplayer-tool RubyGem to download. 
    #
    # It's important to note that this version number
    # will differ slightly from the actual player version in that the final revision 
    # (the last of three numbers), is the gem version, while the first two describe the player
    # version being downloaded.
    # The exact gem version that you would like the ToolTask to execute. By default this value
    # should be nil and will download the latest version of the gem that is available unless
    # there is a version already installed on your system. 
    # 
    # This attribute could be an easy
    # way to update your local gem to the latest version without leaving your build file,
    # but it's primary purpose is to allow you to specify very specific versions of the tools
    # that your project depends on. This way your team can rest assured that they are all
    # working with the same tools.
    def gem_version=(version)
      @gem_version = version
    end
    
    def gem_version
      return @gem_version ||= nil
    end
    
    # Full name of the sprout tool gem that this tool task will use. 
    # This defaults to sprout-flashplayer-tool
    def gem_name=(name)
      @gem_name = name
    end

    def gem_name
      return @gem_name ||= @default_gem_name
    end
    
    # The File where JUnit test results should be written. This value
    # defaults to 'AsUnitResults.xml'
    #
    def test_result_file=(file)
      @test_result_file = file
    end

    def test_result_file
      @test_result_file ||= @default_result_file
    end
    
    def test_result
      @test_result ||= ''
    end

    def define # :nodoc:
      CLEAN.add(test_result_file)
    end

    def execute(*args)
      super
      raise FlashPlayerError.new("FlashPlayer task #{name} required field swf is nil") unless swf
      
      log_file = nil

      # Don't let trust or log file failures break other features...
      begin
        config = FlashPlayerConfig.new
        log_file = config.log_file
        FlashPlayerTrust.new(File.expand_path(File.dirname(swf)))

        if(File.exists?(log_file))
          File.open(log_file, 'w') do |f|
            f.write('')
          end
        else
          FileUtils.makedirs(File.dirname(log_file))
          FileUtils.touch(log_file)
        end
      rescue StandardError => e
        puts '[WARNING] FlashPlayer encountered an error working with the mm.cfg log and/or editing the Trust file'
      end
      
      @running_process = nil
      @thread = run(gem_name, gem_version, swf)
      read_log(@thread, log_file) unless log_file.nil?
      @thread.join
    end

    def run(tool, gem_version, swf)
      path_to_exe = Sprout.get_executable(tool, nil, gem_version)
      target = User.clean_path(path_to_exe)
      @player_pid = nil
      
      thread_out = $stdout
      command = "#{target} #{User.clean_path(swf)}"

      usr = User.new()
      if(usr.is_a?(WinUser) && !usr.is_a?(CygwinUser))
        return Thread.new {
            system command
        }
      elsif usr.is_a?(OSXUser)
        require 'clix_flash_player'
        @clix_player = CLIXFlashPlayer.new
        @clix_player.execute(target, swf)
        return @clix_player
      else
        return Thread.new {
          require 'open4'
          @player_pid, stdin, stdout, stderr = Open4.popen4(command)
          stdout.read
        }
      end
    end
    
    def close
      usr = User.new
      if(usr.is_a?(WinUser))
        Thread.kill(@thread)
      elsif(usr.is_a?(OSXUser))
        @clix_player.kill unless @clix_player.nil?
      else
        Process.kill("SIGALRM", @player_pid)
      end
    end
    
    def read_log(thread, log_file)
      lines_put = 0

      if(log_file.nil?)
        raise FlashPlayerError.new('[ERROR] Unable to find the trace output log file because the expected location was nil')
      end

      if(!File.exists?(log_file))
        raise FlashPlayerError.new('[ERROR] Unable to find the trace output log file in the expected location: ' + log_file)
      end

      while(thread.alive?)
        sleep(0.2)
        lines_read = 0

        File.open(log_file, 'r') do |file|
          file.readlines.each do |line|
            lines_read = lines_read + 1
            if(lines_read > lines_put)
              if(!parse_test_result(line, thread))
                puts "[trace] #{line}"
              end
              $stdout.flush
              lines_put = lines_put + 1
            end
          end
        end
      end
    end

    # Returns true if inside of a test result
    def parse_test_result(line, thread)
      if(@inside_test_result)
        if(line.index(@@test_result_post_delimiter))
          @inside_test_result = false
          write_test_result(test_result)
          close
          examine_test_result test_result
          return true
        else
          test_result << line
        end
      end

      if(line.index(@@test_result_pre_delimiter))
        @inside_test_result = true
      end
      
      return @inside_test_result
    end
    
    def write_test_result(result)
      FileUtils.makedirs(File.dirname(test_result_file))
      File.open(test_result_file, File::CREAT|File::TRUNC|File::RDWR) do |f|
        f.puts(result)
      end
    end

    def examine_test_result(result)
      require 'rexml/document'
      doc = nil
      begin
        doc = REXML::Document.new(result)
      rescue REXML::ParseException => e
        puts "[WARNING] Invalid test results encountered"
        return
      end
      
      # Handle JUnit Failures
      failures = []

      doc.elements.each('/testsuites/testsuite/testsuite/testcase/error') do |element|
        failures << element.text
      end

      doc.elements.each("/testsuites/testsuite/testsuite/testcase/failure") do |element|
        failures << element.text
      end

      if(failures.size > 0)
        raise AssertionFailure.new("[ERROR] Test Failures Encountered \n#{failures.join("\n")}")
      end
    end

  end

  ##########################################
  # FlashPlayerConfig Class

  class FlashPlayerConfig # :nodoc:

    @@file_name = 'mm.cfg'

    def log_file
      create_config_file
      path = File.join(FlashPlayerTask.home, 'Logs', 'flashlog.txt')
      if(User.new().is_a?(CygwinUser))
        parts = path.split("/")
        parts.shift()
        part = parts.shift() # shift cygdrive
        if(part != 'cygdrive')
          Log.puts "[WARNING] There may have been a problem writing mm.cfg, please check the path in #{@config} and make sure it's a windows path..."
          return path
        end
        drive = parts.shift()
        parts.unshift(drive.upcase + ":")
        path = parts.join("/")
      end
      return path
    end

    def content(file)
      return <<EOF
ErrorReportingEnable=1
MaxWarnings=0
TraceOutputEnable=1
TraceOutputFileName=#{file}
EOF
    end

    def create_config_file
      path = config_path 

      if(file_blank?(path))
        write_config(path, content(path))
      end

      path
    end

    private

    def file_blank?(file)
      !File.exists?(file) || File.read(file).empty?
    end

    def config_path
      osx_fp9 = File.join(User.library, 'Application Support', 'Macromedia')
      if(FlashPlayerTask.home == osx_fp9)
        path = File.join(osx_fp9, @@file_name)
      else
        path = File.join(User.home, @@file_name)
      end
      path
    end

    def user_confirmation?(location)
      puts <<EOF

Correctly configured mm.cfg file not found at: #{location}

This file is required in order to capture trace output.

Would you like this file created automatically? [Yn]

EOF
      answer = $stdin.gets.chomp.downcase
      return (answer == 'y' || answer == '')
    end

    def write_config(location, content)
      if(user_confirmation?(location))
        File.open(location, 'w') do |f|
          f.write(content)
        end
        Log.puts ">> Created file: " + File.expand_path(location)
      else
        raise FlashPlayerError.new("[ERROR] Unable to create mm.cfg file at: #{location}")
      end
    end
  end

  ##########################################
  # FlashPlayerTrust Class

  class FlashPlayerTrust # :nodoc:

    def initialize(path)
      trust_file = FlashPlayerTask.trust
      if(!File.exists?(trust_file))
       FileUtils.mkdir_p(File.dirname(trust_file))
       FileUtils.touch(trust_file)
      end

      parts = path.split(File::SEPARATOR)
      if(parts.size == 1)
        path = File::SEPARATOR + path
      end

      if(!has_path?(trust_file, path))
        File.open(trust_file, 'a') do |f|
          f.puts path
        end
        Log.puts ">> Added #{path} to Flash Player Trust file at: #{trust_file}"
      end
    end

    def has_path?(file, path)
      File.open(file, 'r') do |f|
        return (f.read.index(path))
      end
    end
  end

end

def flashplayer(args, &block)
  Sprout::FlashPlayerTask.define_task(args, &block)
end

