module Sprout
  class Preprocessor
    attr_accessor :command
    attr_accessor :paths
    attr_accessor :temp_dir
    attr_accessor :temp_files
    
    def initialize
      @command = 'cpp -P - -'
      @paths = []
      @temp_dir = '.processed'
      @temp_files = []
    end
    
    def execute 
      yield self if block_given?
      FileUtils.mkdir_p(@temp_dir)
    end
    
    # todo:: promp for confirmation before deleting
    def unexecute
      if(File.exists? @temp_dir) 
        FileUtils.rm_rf(@temp_dir)
      end
    end
  end
end