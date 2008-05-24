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

require 'zip/zipfilesystem'

# TODO: Make this task more like a rake FileTask
# The output should be the task name and the input
# files should be added as prerequisites

module Sprout
  class ZipError < StandardError #:nodoc:
  end

  # The ZipTask should accept any directory as input and either
  # an expected zip file name or directory where one will be created
  # for output.
  # The resulting zip file will only be generated if a file in the
  # input directory has a newer timestamp than the existing zip file
  class ZipTask < Rake::FileTask

    # Array of file names that should not be added to the zip archive.
    # The default value of this property is:
    #   @excludes = ['.', '..', '.svn', '.cvs', '.DS_Store', '.git', 'CVS', 'Thumbs.db']
    attr_writer :excludes
    # The file or folder that should be archived. 
    #
    # If input is a directory, all of it's contents
    # will be recursively added to the archive (excluding any files that match +excludes+ of course).
    #
    # If input is a file, a new archive will be created with a similar file name and only that file
    # will be added to the archive.
    attr_writer :input
    # Zip archive file to create. Usually, the name of the zip task will be used for this property,
    # but in cases where you want a particular task name and a different output file, you can set
    # this parameter.
    attr_writer :output
    
    def self.define_task(args, &block) # :nodoc:
      t = super
      yield t if block_given?
      t.define
    end
    
    def define # :nodoc:
      @input = define_input(input)
      @output = define_output(output || name)
    end
    
    def output
      @output ||= nil
    end
    
    def input
      @input ||= nil
    end

    def execute(*args) # :nodoc:
      create_archive
    end
    
    def excludes
      @excludes ||= ['.', '..', '.svn', '.cvs', '.DS_Store', '.git', 'CVS', 'Thumbs.db']
    end

    private
    
    def create_archive(force=false) # :nodoc:
      return unless (force || name == output)
      
      start = Dir.pwd
      begin
        full_output = File.expand_path(output)
        full_input = File.expand_path(input)
        Dir.chdir(File.dirname(full_input))
        masked_input = full_input.gsub("#{Dir.pwd}/", '')

        # Create the containing folder for output
        if(!File.directory?(File.dirname(full_output)))
          FileUtils.mkdir_p(File.dirname(full_output))
        end
        
        ZipUtil.pack(masked_input, full_output, excludes)
  
      ensure
        Dir.chdir(start)
      end
    
    end

    def define_input(input)
      file input do |t|
        raise ZipError.new("ZipTask '#{name}' could not find valid input at: #{input}") unless (File.exists?(input))
      end

      input_files = FileList["#{input}/**/**/*"]
      input_files.each do |f|
        prerequisites << f
      end
      prerequisites << input
      return input
    end
    
    def define_output(out)
      
      # If the provided parent dir doesn't
      # exist, create it
      if(!File.exists?(File.dirname(out)))
        FileUtils.mkdir_p(File.dirname(out))
      end

      # If the provided output is just a directory
      # and it's parent doesn't yet exist, create the
      # provided output directory before appending
      # the real zip file name
      if(!File.basename(out).index('.'))
        FileUtils.mkdir_p(out)
      end
      
      # If out is just a directory, append input's basename
      # to create the zip file
      if(File.directory?(out))
        out = File.join(out, File.basename(input) + '.zip')
      end
      
      if(out != name)
        file out do
          create_archive(true)
        end
        prerequisites << out
      end
      return out
    end
  end
end

def zip(args, &block)
  Sprout::ZipTask.define_task(args, &block)
end
