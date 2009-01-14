require 'git'
require 'sprout/version_file'

module Sprout
  
  class GitTaskError < StandardError; end
  
  class GitTask < Rake::Task
    attr_accessor :version_file
    attr_accessor :scm
    
    def initialize(name, app)
      super
    end
    
    def version
      @version.to_s
    end
    
    def define
      validate
      @version = VersionFile.new(version_file)
    end
    
    def execute(*args)
      super
      # Fix numeric comparison....
      while(get_tags.index(@version.to_tag)) do
        @version.increment_revision
      end
      create_tag(@version.to_tag)
      @scm.push('origin', 'master', true)
    end

    def self.define_task(args, &block)
      t = super
      yield t if block_given?
      t.define
      return t
    end
    
    private
    
    def path_to_git
      git = '.git'
      parts = Dir.pwd.split(File::SEPARATOR)
      return git if(File.exists?(git))
      
      while(parts.size > 0) do
        joined = File.join(parts.join(File::SEPARATOR), git)
        if(File.exists?(joined))
          return joined
        end
        parts.pop
      end
      
      return nil
    end
    
    def get_tags
      return @scm.tags.collect do |t|
        t.name
      end
    end
    
    def create_tag(name)
      @scm.add_tag name
    end
    
    def validate
      raise GitTaskError.new('version_file is a required configuration for GitTask') if version_file.nil?
      if(@scm.nil?)
        path = path_to_git
        raise GitTaskError.new("We don't appear to be inside of a git repository") if path.nil?
        @scm = Git.open(path)
      end
    end
    
  end

end

# Helper method for definining the git task in a rakefile
def git(args, &block)
  Sprout::GitTask.define_task(args, &block)
end