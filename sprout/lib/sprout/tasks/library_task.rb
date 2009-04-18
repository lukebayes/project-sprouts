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
  class LibraryError < StandardError #:nodoc:
  end

  # :include: ../../../doc/Library
  class LibraryTask < Rake::Task
    
    # The RubyGems gem version string for this library (e.g., +version = '0.0.1'+)
    attr_accessor :version

    attr_writer :gem_name # :nodoc:
    attr_writer :project_lib # :nodoc:

    def self.define_task(args, &block) # :nodoc:
      t = super
      yield t if block_given?
      t.define
    end

    # The full gem name like 'sprout-asunit3-library'
    def gem_name
      @gem_name ||= "sprout-#{clean_name}-library"
    end
    
    # Ensure that namespaced rake tasks only use
    # the final part for name-based features
    def clean_name
      return name.split(':').pop
    end
    
    # The path to the library source or swc that will be copied into your project.
    # This can actually be any full or relative path on your system, but should almost
    # always be left alone for automatic resolution.
    def library_path
      @library_path ||= nil
    end
    
    # Override the the project folder where the library will be installed.
    # 
    # By default, libraries are installed into Sprout::ProjectModel +lib_dir+.
    def project_lib
      if(library_path.index('.swc'))
        @project_lib ||= ProjectModel.instance.swc_dir
      else
        @project_lib ||= ProjectModel.instance.lib_dir
      end
    end
    
    # Unlike other rake tasks, Library tasks are actually 
    # resolved at 'define' time. This allows the tool tasks
    # to build their own dependencies (like file deps)
    #   (I'm sure there's a better way to do this, if you know how to fix this, 
    # and would like to contribute to sprouts, this might be a good spot for it)
    def define
      @file_target = sprout(gem_name, version)
      @library_path = File.join(@file_target.installed_path, @file_target.archive_path)
      define_file_task(library_path, project_path)
    end
    
    def execute(*args) # :nodoc:
      super
    end

    # The path within the project where this library is installed
    def project_path
      if(File.directory?(@library_path))
        # library is source dir
        File.join(project_lib, clean_name)
      else
        # library is a binary (like swc, jar, etc)
        File.join(project_lib, File.basename(@file_target.archive_path))
      end
    end
    
    private
    
    def define_file_task(source, destination)
      file destination do |t|
        FileUtils.mkdir_p(destination)
        puts "destination: #{destination}"
        FileUtils.cp_r(library_path, destination)
      end
      prerequisites << destination
    end
    
  end
end

# Helper method for definining and accessing LibraryTask instances in a rakefile
def library(args, &block)
  Sprout::LibraryTask.define_task(args, &block)
end
