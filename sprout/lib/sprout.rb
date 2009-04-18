require 'rubygems'
require 'archive/tar/minitar'
require 'rake'
require 'rake/clean'

# This is a fix for Issue #106
# http://code.google.com/p/projectsprouts/issues/detail?id=106
# Which is created because the new version (1.0.1) of RubyGems
# includes open-uri, while older versions do not.
# When open-uri is included twice, we get a bunch of nasty
# warnings because constants are being overwritten.
if(Gem::Version.new(Gem::RubyGemsVersion) != Gem::Version.new('1.0.1')) 
  require 'open-uri'
end

$:.push(File.dirname(__FILE__))
require 'progress_bar'
require 'sprout/log'
require 'sprout/user'
require 'sprout/zip_util'
require 'sprout/remote_file_target'
require 'sprout/remote_file_loader'
require 'sprout/remote_file_unpacker'
require 'sprout/simple_resolver'
require 'sprout/template_resolver'

require 'rubygems/installer'
require 'rubygems/source_info_cache'
require 'rubygems/version'
require 'rubygems/digest/md5'

require 'sprout/project_model'
require 'sprout/builder'
require 'sprout/version'
require 'sprout/tasks/tool_task'
require 'sprout/general_tasks'
require 'sprout/generator'

module Sprout
  if(!defined? SUDO_INSTALL_GEMS)
    SUDO_INSTALL_GEMS = 'false' == ENV['SUDO_INSTALL_GEMS'] ? false : true
  end

  class SproutError < StandardError #:nodoc:
  end

  # Sprouts is an open-source, cross-platform project generation and configuration tool
  # for ActionScript 2, ActionScript 3, Adobe AIR and Flex projects. It is built on top 
  # of Ruby Gems, Rubigen Generators and is intended to work on any platform that Ruby runs
  # on including specifically, Windows XP, Windows Vista, Cygwin, OS X and Linux.
  #
  # Sprouts can be separated into some core concepts as follows:
  #
  # ----
  # == Tools
  # :include: ../doc/Tool
  #
  # ----
  # == Libraries
  # :include: ../doc/Library
  # 
  # ----
  # == Bundles
  # :include: ../doc/Bundle
  #
  # ----
  # == Generators
  # :include: ../doc/Generator
  #
  # ----
  # == Tasks
  # :include: ../doc/Task
  #
  # ----
  # == Sprout
  #
  # Tools, Libraries and Bundles are distributed as RubyGems and given a specific gem name suffix. For some examples:
  #   sprout-flex3sdk-tool
  #   sprout-asunit-library
  #   sprout-as3-bundle
  #
  # The Sprout application provides shared functionality for each of the different types of Sprouts.
  # 
  # The Sprout command line tool primarily provides access to project generators from any sprout bundle that is available
  # to your system, either locally or from the network.
  # 
  # When executed from the system path, this class will download and install a named bundle, and execute a +project+
  # generator within that bundle. Following is an example:
  # 
  #   sprout -n as3 SomeProject
  #
  # The previous command will download and install the latest version of the sprout-as3-bundle gem and initiate the 
  # project_generator with a single argument of 'SomeProject'. If the string passed to the -n parameter begins with
  # 'sprout-' it will be unmodified for the lookup. For example:
  #
  #   spout -n sprout-as3-bundle SomeProject
  #
  # will not have duplicate strings prepended or suffixed.
  #
  # ----
  # Some additional resources or references:
  #
  # Rake:
  # http://rake.rubyforge.org
  # http://martinfowler.com/articles/rake.html
  #
  # RubyGems:
  # * http://www.rubygems.org
  # * http://www.linuxjournal.com/article/8967
  #
  # Ruby Raven (Mostly Inspiration)
  # * http://raven.rubyforge.org
  #
  class Sprout
    @@default_rakefiles = ['rakefile', 'Rakefile', 'rakefile.rb', 'Rakefile.rb'].freeze

    @@name      = 'Sprouts'
    @@cache     = 'cache'
    @@lib       = 'lib'
    @@spec      = 'sprout.spec'
    @@home  = File.expand_path(File.dirname(File.dirname(__FILE__)))

    # Execute a generator that is available locally or from the network.
    # * +sprout_name+ A full gem name (ex., sprout-as3-bundle) that contains a generator that matches +generator_name+
    # * +generator_name+ A string like 'project' or 'class' that maps to a generator
    # * +params+ Arbitrary parameters to pass to the generator
    # * +project_path+ Optional parameter. Will default to the nearest folder that contains a valid Rakefile.
    # This Rakefile will usually be loaded by the referenced Generator, and it should have a configured ProjectModel
    # defined in it.
    def self.generate(sprout_name, generator_name, params, project_path=nil)
      RubiGen::Base.use_sprout_sources!(sprout_name, project_path)
      generator = RubiGen::Base.instance(generator_name, params)
      generator.command(:create).invoke!
    end
    
    # Remove all installed RubyGems that begin with the string 'sprout' and clear the local sprout cache
    def self.remove_all
      # Set up sudo prefix if not on win machine
      # Only show confirmation if there is at least one installed sprout gem
      confirmation = false
      count = 0
      # For each sprout found, remove it!
      RubiGen::GemGeneratorSource.new().each_sprout do |sprout|
        count += 1
        command = "#{get_gem_preamble} uninstall -x -a -q #{sprout.name}"

        if(!confirmation)
          break unless confirmation = remove_gems_confirmation
        end
        puts "executing #{command}"
        raise ">> Exited with errors: #{$?}" unless system(command)
      end
      
      if(confirmation)
        puts "All Sprout gems have been successfully uninstalled"
      elsif(count > 0)
        puts "Some Sprout gems have been left on the system"
      else
        puts "No Sprout gems were found on this system"
      end

      # Now clear out the cache
      cache = File.dirname(File.dirname(Sprout.sprout_cache))
      
      if(File.exists?(cache))
        puts "\n[WARNING]\n\nAbout to irrevocably destroy the sprout cache at:\n\n#{cache}\n\n"
        puts "Are you absolutely sure? [Yn]"
        response = $stdin.gets.chomp!
        if(response.downcase.index('y'))
          FileUtils.rm_rf(cache)
        else
          puts "Leaving the Sprout file cache in tact...."
        end
      else
        puts "No cached files found on this system"
      end
      
      puts "To completely remove sprouts now, run:"
      puts "  #{get_gem_preamble} uninstall sprout"
    end
    
    # Build up the platform-specific preamble required
    # to call the gem binary from Kernel.execute
    def self.get_gem_preamble
      usr = User.new()
      if(!usr.is_a?(WinUser))
        # Everyone but Win and Cygwin users get 'sudo '
        return "#{SUDO_INSTALL_GEMS ? 'sudo ' : ''}gem"
      elsif(!usr.is_a?(CygwinUser))
        # We're in the DOS Shell
        return "ruby #{get_executable_from_path('gem')}"
      end
      # We're either a CygwinUser or some other non-sudo supporter
      return 'gem'
    end
    
    # Retrieve the full path to an executable that is
    # available in the system path
    def self.get_executable_from_path(exe)
      path = ENV['PATH']
      file_path = nil
      path.split(get_path_delimiter).each do |p|
        file_path = File.join(p, exe)
#        file_path = file_path.split("/").join("\\")
#        file_path = file_path.split("\\").join("/")
        if(File.exists?(file_path))
          return User.clean_path(file_path)
        end
      end
      return nil
    end
    
    def self.get_path_delimiter
      usr = User.new
      if(usr.is_a?(WinUser) && !usr.is_a?(CygwinUser))
        return ';'
      else
        return ':'
      end
    end
    
    def self.remove_gems_confirmation
      msg =<<EOF 
About to uninstall all RubyGems that match 'sprout-'....
Are you sure you want to do this? [Yn]
EOF
      puts msg
      response = $stdin.gets.chomp!
      if(response.downcase.index('y'))
        return true
      end
      return false
    end

    # Retrieve the file target to an executable by sprout name. Usually, these are tool sprouts.
    # * +name+ Full sprout gem name that contains an executable file
    # * +archive_path+ Optional parameter for tools that contain more than one executable, or for
    # when you don't want to use the default executable presented by the tool. For example, the Flex 2 SDK
    # has many executables, when this method is called for them, one might use something like:
    #   Sprout::Sprout.get_executable('sprout-flex3sdk-tool', 'bin/mxmlc')
    # * +version+ Optional parameter to specify a particular gem version for this executable
    def self.get_executable(name, archive_path=nil, version=nil)
      target = self.sprout(name, version)
      if(archive_path)
        # If caller sent in a relative path to an executable (e.g., bin/mxmlc), use it
        exe = File.join(target.installed_path, archive_path)
        if(User.new.is_a?(WinUser) && !archive_path.match(/.exe$/))
          # If we're on Win (even Cygwin), add .exe to support custom binaries (see sprout-flex3sdk-tool)
          exe << '.exe'
        end
      elsif(target.url)
        # Otherwise, use the default path to an executable if the RemoteFileTarget has a url prop
        exe = File.join(target.installed_path, target.archive_path)
      else
        # Otherwise attempt to run the feature from the system path
        exe = target.archive_path
      end
      
      if(File.exists?(exe) && !File.directory?(exe) && File.stat(exe).executable?)
        File.chmod 0755, exe
      end
      
      return exe
    end

    # Allows us to easily download and install RubyGem sprouts by name and 
    # version. 
    # Returns a RubyGem Gem Spec[http://rubygems.org/read/chapter/20]
    # when installation is complete. If the installed gem has a Ruby file
    # configured to 'autorequire', that file will also be required by this
    # method so that any provided Ruby functionality will be immediately 
    # available to client scripts. If the installed gem contains a 
    # 'sprout.spec' file, any RemoteFileTargets will be resolved synchronously
    # and those files will be available in the Sprout::Sprout.cache.
    #
    def self.sprout(name, version=nil)
      name = sprout_to_gem_name(name)
      gem_spec = self.find_gem_spec(name, version)
      sprout_spec_path = File.join(gem_spec.full_gem_path, @@spec)
      
      if(gem_spec.autorequire)
        $:.push(File.join(gem_spec.full_gem_path, 'lib'))
        require gem_spec.autorequire
      end
      if(File.exists?(sprout_spec_path))
        # Ensure the requisite files get downloaded and unpacked
        Builder.build(sprout_spec_path, gem_file_cache(gem_spec.name, gem_spec.version))
      else
        return gem_spec
      end
    end
    
    # Return sprout-#{name}-bundle for any name that does not begin with 'sprout-'. This was used early on in development
    # but should possibly be removed as we move forward and try to support arbitrary RubyGems.
    def self.sprout_to_gem_name(name)
      if(!name.match(/^sprout-/))
        name = "sprout-#{name}-bundle"
      end
      return name
    end

    # Return the home directory for this Sprout installation
    def self.home
      return @@home
    end
    
    # Return the location on disk where this installation of Sprouts stores it's cached files.
    # If the currently installed version of Sprouts were 0.7 and your system username were 'foo'
    # this would return the following locations:
    # * +OSX+ /Users/foo/Library/Sprouts/cache/0.7
    # * +Windows+ C:/Documents And Settings/foo/Local Settings/Application Data/Sprouts/cache/0.7
    # * +Linux+ ~/.sprouts/cache/0.7
    def self.sprout_cache
      home = User.application_home(@@name)
      return File.join(home, @@cache, "#{VERSION::MAJOR}.#{VERSION::MINOR}")
    end
    
    # Return the +sprout_cache+ combined with the passed in +name+ and +version+ so that you will get
    # a cache location for a specific gem.
    def self.gem_file_cache(name, version)
      return File.join(sprout_cache, "#{name}-#{version}")
    end
    
    # Retrieve the RubyGems gem spec for a particular gem +name+ that meets the provided +requirements+.
    # +requirements+ are provided as a string value like:
    #   '>= 0.0.1'
    # or
    #   '0.0.1'
    # This method will actually download and install the provided gem by +name+ and +requirements+ if
    # it is not found locally on the system.
    def self.find_gem_spec(name, requirements=nil, recursed=false)
      specs = Gem::cache.sprout_search(/.*#{name}$/).reverse # Found specs are returned in order from oldest to newest!?
      requirement = nil
      if(requirements)
        requirement = Gem::Requirement.new(requirements)
      end
      specs.each do |spec|
        if(requirements)
          if(requirement.satisfied_by?(spec.version))
            return spec
          end
        else
          return spec
        end
      end

      if(recursed)
        raise SproutError.new("Gem Spec not found for #{name} #{requirements}")
      else
        msg = ">> Loading gem [#{name}]"
        msg << " #{requirements}" if requirements
        msg << " from #{gem_sources.join(', ')} with its dependencies"
        Log.puts msg
        parts = [ 'ins', '-r', name ]
        # This url should be removed once released, released gems should be hosted from the rubyforge
        # project, and development gems will be hosted on our domain.
        parts << "--source #{gem_sources.join(' --source ')}" if(Log.debug || name.index('sprout-'))
        parts << "-v #{requirements}" unless requirements.nil?

        self.load_gem(parts.join(" "))
        Gem::cache.refresh!
        return find_gem_spec(name, requirements, true)
      end
    end
    
    def self.load_gem(args)
      # This must use a 'system' call because RubyGems
      # sends an 'exit'?
      system("#{get_gem_preamble} #{args}")
    end
    
    ##
    # List of files to ignore when copying project templates
    # These files will not be copied
    @@COPY_IGNORE_FILES = ['.', '..', '.svn', '.DS_Store', 'CVS', '.cvs' 'Thumbs.db', '__MACOSX', '.Trashes', 'Desktop DB', 'Desktop DF']
    # Do not copy files found in the ignore_files list
    def self.ignore_file? file
      @@COPY_IGNORE_FILES.each do |name|
        if(name == file)
          return true
        end
      end
      return false
    end
    
    def self.gem_sources=(sources) # :nodoc:
      if(sources.is_a?(String))
        # TODO: Clean up the string that is sent in,
        # maybe even split space or comma-delimited?
        sources = [sources]
      end
      @@gem_sources = sources
    end
    
    # TODO: Should be updated after release so that all gems are 
    # loaded form rubyforge instead of projectsprouts, only development
    # gems will continue to be hosted at this default domain.
    def self.gem_sources # :nodoc:
      @@gem_sources ||= ['http://gems.rubyforge.org']
    end

    def self.project_name=(name) # :nodoc:
      @@project_name = name
    end
    
    # Return the current project_name assuming someone has already set it, otherwise return an empty string
    def self.project_name
      @@project_name ||= ''
    end
    
    def self.project_path=(path) # :nodoc:
      @@project_rakefile = child_rakefile(path)
      @@project_path = path
    end
    
    # project_path should step backward in the file system
    # until it encounters a rakefile. The parent directory
    # of that rakefile should be returned.
    # If no rakefile is found, it should return Dir.pwd
    def self.project_path
      @@project_path ||= self.project_path = get_implicit_project_path(Dir.pwd)
    end
    
    # Return the rakefile in the current +project_path+
    def self.project_rakefile
      if(!defined?(@@project_rakefile))
        path = project_path
      end
      return @@project_rakefile ||= nil
    end

    # Look in the provided +dir+ for files that meet the criteria to be a valid Rakefile.
    def self.child_rakefile(dir)
      @@default_rakefiles.each do |file|
        rake_path = File.join(dir, file)
        if(File.exists?(rake_path))
          return rake_path
        end
      end
      return nil
    end

    def self.get_implicit_project_path(path)
      # We have recursed to the root of the filesystem, return nil
      if(path.nil? || path == '/' || path.match(/[A-Z]\:\//))
        return Dir.pwd
      end
      # Look for a rakefile as a child of the current path
      if(child_rakefile(path))
        return path
      end
      # No rakefile and no root found, check in parent dir
      return Sprout.get_implicit_project_path(File.dirname(path))
    end

  end
end

# Set an array of URLs to use as gem repositories when loading Sprout gems.
# Any rakefile that requires the sprout gem can use this method as follows:
#
#   set_sources ['http://gems.yourdomain.com']
#
def set_sources(sources)
  Sprout::Sprout.gem_sources = sources
end

# Helper method that will download and install remote sprouts by name and version
def sprout(name, version=nil)
  Sprout::Sprout.sprout(name, version)
end
