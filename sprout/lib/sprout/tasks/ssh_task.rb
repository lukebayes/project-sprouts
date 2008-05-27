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
  class SSHError < StandardError #:nodoc:
  end

  # The SSHTask allows you to execute arbitrary commands on a remote host.
  #
  #   ssh :update_gem_index do |t|
  #     t.host = 'dev.projectsprouts.com'
  #     t.username = 'someUser'
  #     t.commands << 'cd /var/www/projectsprouts/current/gems'
  #     t.commands << 'gem generate_index -d .'
  #   end
  #
  class SSHTask < Rake::Task

    # Host name of the server to connect to with no protocol prefix, like: sub.yourhost.com
    attr_accessor :host
    # Array of commands that will be executed on the remote machine
    attr_accessor :commands
    # Username to send to the remote host. You will be prompted for this value if it is left null. 
    attr_accessor :username
    # Password to send to the remote host. You will be prompted for this value if it is left null.
    #
    # NOTE: You should never check a file into version control with this field filled in, it is
    # provided here as a convenience for getting set up.
    attr_accessor :password

    def initialize(task_name, app)
      super(task_name, app)
      @name = name
      @host = nil
      @queue = []
      @commands = []
    end

    def self.define_task(args, &block) # :nodoc:
      t = super
      yield t if block_given?
    end
    
    def execute(*args) # :nodoc:
      if(@host.nil?)
        throw SSHError.new('SSH requires a valid host parameter')
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

      puts ">> Connecting to Remote Server: #{@username}@#{@host}:#{@remote_path}"      
      Net::SSH.start(@host, @username, @password) do |session|
        session.open_channel do |channel|
          commands.each do |command|
            puts ">> #{command}"
            channel.exec command
          end
          channel.close
        end
        session.loop
      end
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


def ssh(args, &block)
  Sprout::SSHTask.define_task(args, &block)
end
