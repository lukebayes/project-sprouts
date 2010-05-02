
module Sprout::User

  class UnixUser < BaseUser

    def clean_path path
      repair_executable path

      if(path.index(' '))
        return path.split(' ').join('\ ')
      end
      return path
    end

  end
end

