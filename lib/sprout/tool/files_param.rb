module Sprout

  # Concrete param object for collections of files
  class FilesParam < StringsParam # :nodoc:

    def prepare
      super
      usr = User.new
      path = nil
      value.each_index do |index|
        path = value[index]
        value[index] = usr.clean_path path
      end
    end

    def prepare_prerequisites
      if should_preprocess?
        @value = prepare_preprocessor_files(value)
      else
        value.each do |f|
          file f
          belongs_to.prerequisites << f
        end
      end
    end

  end

end

