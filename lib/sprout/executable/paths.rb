module Sprout

  module Executable

    ##
    # A collection of Paths.
    #
    # @see Sprout::Executable::Path
    # @see Sprout::Executable::Param
    # @see Sprout::Executable::CollectionParam
    #
    class Paths < Files 

      def prepare_prerequisites
        value.each do |path|
          files = FileList[path + file_expression]
          files.each do |f|
            Rake::FileTask.define_task f
            belongs_to.prerequisites << f
          end
        end
      end
    end
  end
end

