require 'git'
require 'sprout/version_file'

module Sprout
  
  class GitTaskError < StandardError; end
  
  # A Rake task for continous integration and automated deployment.
  # This task will automatically load a +version_file+, increment
  # the last digit (revision), create a new tag in Git with the full
  # version number, and push tags to the remote Git repository.
  #
  # To use this task, simply add the following to your rakefile:
  #
  #   desc 'Increment revision, tag and push with git'
  #   git :tag do |t|
  #     t.version_file = 'version.txt'
  #   end
  #
  
  class GitTask < Rake::Task
    # Path to a plain text file that contains a three-part version number.
    # @see VersionFile
    attr_accessor :version_file
    # Accessor for mocking the git gem.
    attr_accessor :scm
    # The remote branch to use, defaults to 'origin'.
    attr_accessor :remote
    # The local branch to send, defaults to 'master'.
    attr_accessor :branch
    # Message to use when committing after incrementing revision number.
    # Defaults to 'Incremented revision number'.
    attr_accessor :commit_message
    
    def initialize(name, app)
      super
      @remote = 'origin'
      @branch = 'master'
      @commit_message = 'Incremented revision number'
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
      commit
      push
    end

    def self.define_task(args, &block)
      t = super
      yield t if block_given?
      t.define
      return t
    end
    
    private
    
    def push
      `git push #{remote} #{branch} --tags`
    end
    
    def commit
      `git commit -a -m "#{commit_message}"`
    end
    
    def path_to_git
      git = '.git'
      parts = Dir.pwd.split(File::SEPARATOR)
      
      while(parts.size > 0) do
        path = parts.join(File::SEPARATOR)
        if(File.exists?(File.join(path, git)))
          return path
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
        @scm.pull
      end
    end
    
  end

end

# Helper method for definining the git task in a rakefile
def git(args, &block)
  Sprout::GitTask.define_task(args, &block)
end