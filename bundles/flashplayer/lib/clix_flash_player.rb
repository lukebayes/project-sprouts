require 'rubygems'
require 'open4'

$CLIX_WRAPPER_TARGET = File.join(File.expand_path(File.dirname(__FILE__)), 'clix_wrapper.rb')

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class CLIXFlashPlayerError < StandardError; end

class CLIXFlashPlayer
  VERSION = '0.1.0'
  
  def initialize
    @activate_pid = nil
    @player_pid = nil
    @thread = nil
  end
  
  def execute(player, swf)
    cleanup
    player = clean_path(player)
    swf = clean_path(swf)
    validate(player, swf)
    
    if(!player.match('Contents/MacOS'))
      player = File.join(player, 'Contents', 'MacOS', 'Flash Player')
    end

    setup_trap
    
    @thread = Thread.new {
      @player_pid = open4.popen4("#{player.split(' ').join('\ ')}")[0]
      begin
        raise "clix_wrapper.rb could not be found at: #{wrapper}" if !File.exists?($CLIX_WRAPPER_TARGET)
        command = "ruby #{$CLIX_WRAPPER_TARGET} '#{player}' '#{swf}'"
        @activate_pid, stdin, stdout, stderr = open4.popen4(command)
        puts stdout.read
        error = stderr.read
        raise error if !error.nil?
        puts "after error"
        # Process.wait(@player_pid)
      rescue StandardError => e
        kill
        raise e
      end
    }
  end
  
  def kill
    system("kill -9 #{@player_pid}")
  end
  
  def join
    if(@thread.alive?)
      @thread.join
    end
  end
  
  def alive?
    return @thread.alive?
  end
  
  private
  
  def clean_path(path)
    File.expand_path(path.gsub("'", '').gsub("\\", ''))
  end
  
  def cleanup
    if(@thread && @thread.alive?)
      kill
      @thread.join
    end
  end
  
  def validate(player, swf)
    raise CLIXFlashPlayerError.new("Player must not be nil") if(player.nil? || player == '')
    raise CLIXFlashPlayerError.new("Player cannot be found: '#{player}'") if(!File.exists?(player))
    raise CLIXFlashPlayerError.new("SWF must not be nil") if(swf.nil? || swf == '')
    raise CLIXFlashPlayerError.new("SWF cannot be found: '#{swf}'") if(!File.exists?(swf))
  end
  
  def setup_trap
    # Trap the CTRL+C Interrupt signal
    # Which prevents nasty exception messages
    Kernel.trap('INT') do
      if(@thread.alive?)
        @thread.kill
      end
    end
  end
  
end

