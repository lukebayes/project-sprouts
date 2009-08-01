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

This class has been commented out because the termios feature
that allows users to more securely enter passwords does not
work in a DOS shell.

It would be greatly appreciate if someone refactored this to either:
a) Get the same functionality in a cross-platform manner
b) Only require and use termios on systems that allow it
=end

#gem 'net-ssh', '1.1.4'
#gem 'net-sftp', '1.1.1'

require 'net/ssh'
require 'net/sftp'

#require 'termios'

module Sprout
  class SFTPError < StandardError #:nodoc:
  end

  # The SFTPTask provides a simple rake task interface to the SFTP client RubyGem.
  # This task can allow you to easily push build artifacts to a remote server 
  # with a single shell command.
  class SFTPTask < Rake::Task

    # Collection of files that should be transmitted to the remote server
    attr_accessor :files
    # Host name of the server to connect to with no protocol prefix, like: sub.yourhost.com
    attr_accessor :host
    # Username to send to the remote host. You will be prompted for this value if it is left null. 
    #
    # NOTE: You should never check a file into version control with this field filled in, it is
    # provided here as a convenience for getting set up.
    attr_accessor :username
    # The mode for transmitted files. Defaults to 0644
    attr_accessor :file_mode
    # the mode for created directories. Defaults to 0755
    attr_accessor :dir_mode
    # The local path to mask from transmitted files. This is key feature for automated file transmission.
    # For example, if you are sending a file:
    #   bin/assets/img/SomeImage.jpg
    # into a directory on your server like:
    #   /var/www/someproject/
    # You don't necessarily want the 'bin' folder copied over, so you set the local_path to 'bin' like:
    #   t.local_path = 'bin'
    # and your server will have the file uploaded to:
    #   /var/www/someproject/assets/img/SomeImage.jpg
    attr_accessor :local_path
    # The Remote base path where files should be transmitted, can be absolute or relative.
    attr_accessor :remote_path
    # Password to send to the remote host. You will be prompted for this value if it is left null.
    #
    # NOTE: You should never check a file into version control with this field filled in, it is
    # provided here as a convenience for getting set up.
    attr_accessor :password

    def initialize(task_name, app)
      super(task_name, app)
      @name = name
      @files = []
      @dir_mode = 0755
      @file_mode = 0644
      @host = nil
    end

    def self.define_task(args, &block) # :nodoc:
      t = super
      yield t if block_given?
    end
    
    def execute(*args) # :nodoc:
      if(@files.size == 0)
        if(@local_path)
          expr = @local_path + '/**/**/*'
          @files = FileList[expr]
        else
          raise SFTPError.new('SFTP requires either a local_path or files to be transmitted')
        end
      else
        if(!@local_path)
          @local_path = ''
        end
      end

      if(@host.nil?)
        raise SFTPError.new('SFTP requires non-nil host parameter')
      end

      if(@username.nil?)
        print "Username: "
        @username = $stdin.gets.chomp!
        raise SFTPError.new('SFTP requires username parameter') unless @username
      end

      if(@password.nil?)
        print "Password: "
        @password = $stdin.gets.chomp!
#        @password = Password.get
        raise SFTPError.new('SFTP requires password parameter') unless @password
      end
    
      if(get_confirmation)
        puts ">> Connecting to Remote Server: #{@username}@#{@host}:#{@remote_path}"
        
        Net::SFTP.start(@host, @username, @password) do |sftp|
          begin
            dir = sftp.opendir(@remote_path)
          rescue Net::SFTP::Operations::StatusException
            puts "[ERROR] [#{@remote_path}] does not exist on the server"
            return
          end
          for file in @files
            next if File.stat(file).directory?
            remote_file = remote_file_name(file)
            put_file(file, remote_file, sftp)
          end
        end
      else
        puts "[WARNING] Publish aborted by user request"
      end
    end
    
    def put_file(local_file, remote_file, sftp) # :nodoc:
      begin
        create_remote_dir(remote_file, sftp)
        
        if(file_changed(local_file, remote_file, sftp))
          puts ">> Pushing #{local_file} to: #{remote_file}"
          sftp.put_file(local_file, remote_file)
        end
      rescue Net::SFTP::Operations::StatusException => e
        raise unless e.code == 2
        sftp.put_file(local_file, remote_file)
        sftp.setstat(remote_file, :permissions => @file_mode)
      end
    end
    
    def create_remote_dir(path, sftp) # :nodoc:
      begin
        sftp.stat(File.dirname(path))
      rescue Net::SFTP::Operations::StatusException => e
        raise unless e.code == 2
        dir = File.dirname(path.sub(@remote_path, ''))
        parts = dir.split(File::SEPARATOR)
        part = File.join(@remote_path, parts.shift)
        while(part)
          begin
            sftp.stat(part)
          rescue Net::SFTP::Operations::StatusException => ne
            raise unless ne.code == 2
            sftp.mkdir(part, :permissions => @dir_mode)
          end
          if(parts.size > 0)
            part = File.join(part, parts.shift)
          else
            part = nil
          end
        end
      end
    end
    
    def file_changed(local_file, remote_file, sftp) # :nodoc:
      local_stat = File.stat(local_file)
      remote_stat = sftp.stat(remote_file)
      time_difference = (local_stat.mtime > Time.at(remote_stat.mtime))
      size_difference = (local_stat.size != remote_stat.size)
      return (time_difference || size_difference)
    end
    
    def remote_file_name(file) # :nodoc:
      return @remote_path + file.sub(@local_path, '')
    end
    
    def get_confirmation # :nodoc:
      puts "-----------------------------------------"
      puts "Are you sure you want to publish #{@files.size} files to:"
      puts "#{@username}@#{@host}:#{@remote_path}? [Yn]"
      response = $stdin.gets.chomp!
      return (response.downcase == 'y' || response == "")
    end
  
  end

=begin
  # The following implementation does not work at all on DOS machines, 
  # is there a cross-platform way to solve the secure password prompt problem?
  # Password handling snippet found at: http://www.caliban.org/ruby/ruby-password.shtml
  class Password

    def Password.get(message="Password: ")
      begin
        if $stdin.tty?
          Password.echo false
          print message if message
        end
  
        return $stdin.gets.chomp
      ensure
        if $stdin.tty?
          Password.echo true
          print "\n"
        end
      end
    end

    def Password.echo(on=true, masked=false)
      term = Termios::getattr( $stdin )
  
      if on
        term.c_lflag |= ( Termios::ECHO | Termios::ICANON )
      else # off
        term.c_lflag &= ~Termios::ECHO
        term.c_lflag &= ~Termios::ICANON if masked
      end
  
      Termios::setattr( $stdin, Termios::TCSANOW, term )
    end
  end
=end
end


def sftp(args, &block)
  Sprout::SFTPTask.define_task(args, &block)
end
