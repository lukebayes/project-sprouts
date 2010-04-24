
module Sprout
  module Library

    #http://rubygems.rubyforge.org/rdoc/Gem/Specification.html
    #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/
    class Specification < Gem::Specification

      required_attribute :file_target

      def assign_defaults
        # Maybe add a closure here?:
        # Gem.post_install_hooks
        #
        # Also check here:
        # Gem.pre_install_hooks

        Gem.pre_install_hooks << proc {
          puts "Gem PRE INSTALL HOOK"
        }
        
        Gem.post_install_hooks << proc {
          puts "Gem POST INSTALL HOOK"
        }
        
        self.rubyforge_project = 'sprout'
        super
      end

      def file_target=(file)
        @file_target = file
        self.files << file
      end

    end
  end
end

