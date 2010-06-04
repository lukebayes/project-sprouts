
module Sprout

  class ExecutableTarget

    attr_reader :name
    attr_reader :path

    def initialize options=nil
      options ||= {}
      @name = options[:name]
      @path = options[:path]

      # You can provide a file_target OR all optional params.
      # kind of smelly...
      @file_target = options[:file_target] if options.has_key? :file_target

      # Optional params:
      @pkg_name    = options[:pkg_name] if options.has_key? :pkg_name
      @pkg_version = options[:pkg_version] if options.has_key? :pkg_version
      @platform    = options[:platform] if options.has_key? :platform
    end

    def pkg_name
      @pkg_name || file_target.pkg_name
    end

    def pkg_version
      @pkg_version || file_target.pkg_version
    end

    def platform
      @platform || file_target.platform
    end

    def resolve
      file_target.resolve unless file_target.nil?
    end

    ##
    # TODO: This should be removed when this 
    # code has been moved to Lookup.
    def includes_package_name? name
      name.to_s.include? pkg_name.to_s
    end

    ##
    # TODO: This should be removed when this
    # code has been moved to Lookup.
    def satisfies_requirement? version_requirement
        return true if version_requirement.nil?
        exe_version = Gem::Version.create pkg_version
        req_version = Gem::Requirement.create version_requirement
        req_version.satisfied_by?(exe_version)
    end

    private

    def file_target
      @file_target ||= Sprout::FileTarget.new
    end

  end
end

