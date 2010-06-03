
module Sprout
  class ToolGenerator < Generator::Base

    add_param :author, String, { :default => 'Unknown' }
    
    add_param :description, String, { :default => 'This is an unconfigured Sprout Tool' }

    add_param :email, String, { :default => 'projectsprout@googlegroups.com' }

    add_param :exe, String, { :default => 'executable_name' }

    add_param :homepage, String, { :default => 'http://projectsprouts.org' }

    add_param :md5, String, { :default => 'd6939117f1df58e216f365a12fec64f9' }

    add_param :summary, String, { :default => 'Sprout Tool' }
    
    add_param :url, String, { :default => 'http://github.com/downloads/lukebayes/project-sprouts/echochamber-test.zip' }

    def manifest
      directory name.snake_case do
        template 'Gemfile'
        template "#{name.snake_case}.gemspec", 'tool.gemspec'
        template "#{name.snake_case}.rb", 'tool.rb'
      end
    end
  end
end

