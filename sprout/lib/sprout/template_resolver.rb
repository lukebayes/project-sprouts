
module Sprout

  class TemplateResolver < Hash #:nodoc:
    include Singleton
    
    attr_accessor :replace_all, 
                  :ignore_all
                  
    @@SPROUT_FILE_NAME = 'Sprout'
    @@RENDER_IGNORE_FILES = ['asclass_config.rb', 'SWFMillTemplate.erb', 'Template.erb']
    @@BINARY_EXTENSIONS = ['.jpg', '.png', '.gif', '.doc', '.xls', '.exe', '.swf', 'fla', '.psd']
    @@LOG_PREFIX = ">> Created file: "
    @@DELETE_PREFIX = ">> Deleted file: "

    def initialize
      super
      @replace_all = false
      @ignore_all = false
    end
    
    def copy_files(from, to, render=false)
      created_files = Array.new
      if(!File.exists? from)
        raise UsageError.new('TemplateResolver attempted to copy files from (' + from + ') but it does not exist...')
      end
      if(File.directory? from)
        Dir.open(from).each do |filename|
          if(!Sprout.ignore_file? filename)
            fullname = File.join(from, filename)
            new_fullname = File.join(to, filename)
            cleaned_filename = clean_file_name(filename)
            cleaned_fullname = File.join(to, cleaned_filename)
            if(File.directory? fullname)
              Dir.mkdir(new_fullname) unless File.exists? new_fullname
              puts new_fullname
              copy_files(fullname, new_fullname, render)
            else
              file = copy_file(fullname, cleaned_fullname, render)
            end
          end
        end
      else
        raise UsageError.new("copy_files called with a file (" + from + ") instead of a directory!")
      end
      
      return created_files
    end
    
    def puts(file, is_delete=false)
      prefix = (is_delete) ? @@DELETE_PREFIX : @@LOG_PREFIX
      Log.puts(prefix + file.gsub(Dir.pwd + '/', ''))
    end
    
    def b(path)
      (is_binary?(path)) ? 'b' : '' 
    end
    
    def copy_file(from, to, render=false, delegate=nil)
      if(write_file?(to))
        content = nil
        File.open(from, 'r' + b(from)) do |f|
          content = f.read
        end
        if(render && should_render?(from))
          begin
            bind = (delegate.nil?) ? binding : delegate.get_binding
            content = ERB.new(content, nil, '>').result(bind)
          rescue NameError => e
            Log.puts '>> Template ' + from + ' references a value that is not defined'
            raise e
          end
        end
        FileUtils.makedirs(File.dirname(to))
        File.open(to, 'w' + b(to)) do |f|
          f.write(content)
        end
        puts to
        return to
      end
      return nil
    end
    
    def should_render?(file)
      if(is_binary?(file) || @@RENDER_IGNORE_FILES.index(File.basename(file)))
        return false
      end
      return true
    end
    
    def write_file?(file)
      if(!File.exists?(file))
        return true
      elsif(@replace_all)
        puts(file, true)
        File.delete(file)
        return true
      elsif(@ignore_all)
        return false
      end

      relative = file.gsub(Dir.pwd, '')
      msg = <<EOF

[WARNING] Sprout Encountered an existing file at [#{relative}], what would you like to do?
(r)eplace, (i)gnore, (R)eplace all or (I)gnore all?

EOF
      if(Log.debug)
        return false
      end

      $stdout.puts msg
      answer = $stdin.gets.chomp
      if(answer == 'r')
        return true
      elsif(answer == 'i')
        return false
      elsif(answer == 'R')
        msg = <<EOF
        
Are you sure you want to replace ALL duplicate files?
(y)es or (n)o

EOF
        $stdout.puts msg
        answer = $stdin.gets.chomp
        if(answer == 'y')
          @replace_all = true
        else
          write_file?(file)
        end
      elsif(answer == 'I')
        @ignore_all = true
        return false
      else
        $stdout.puts "I didn't understand that response... Please choose from the following choices:\n\n"
        write_file?(file)
      end
    end
    
    def render_file filename
      file = File.open(filename, 'r')
      resolved = ERB.new(file.read, nil, '>').result(binding)
      file.close
      file = File.open(filename, 'w')
      file.write(resolved)
      file.close
    end
    
    def clean_file_name name
      return name.gsub(@@SPROUT_FILE_NAME, project_name)
    end
    
    def project_name
      return Sprout.project_name
    end
    
    def instance_name
      return project_name[0,1].downcase + project_name[1,project_name.size]
    end
    
    #TODO: Figure out if the file is plain text or not... Possible?
    def is_binary? file
      file_extension = File.extname(file).downcase
      @@BINARY_EXTENSIONS.each do |ext|
        if(file_extension == ext)
          return true
        end
      end
      return false
    end

=begin
  Found this code for binary inspection here:
  http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/44940
  it's not 100%, but better than what I'm doing with extensions.
  This should be tested and inserted above
  if it works.

  NON_ASCII_PRINTABLE = /[^\x20-\x7e\s]/

  def nonbinary?(io, forbidden, size = 1024)
    while buf = io.read(size)
      return false if forbidden =~ buf
    end
    true
  end

  # usage: ruby this_script.rb filename ...
  ARGV.each do |fn|
    begin
      open(fn) do |f|
        if nonbinary?(f, NON_ASCII_PRINTABLE)
          puts "#{fn}: ascii printable"
        else
          puts "#{fn}: binary"
        end
      end
    rescue
      puts "#$0: #$!"
    end
  end
=end

  end
end