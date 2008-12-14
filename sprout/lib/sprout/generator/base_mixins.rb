
class Gem::SourceIndex
  
  # This feature seems to be getting deprecated from the latest
  # gems releases (1.3.x). 
  # We actually need it and don't want the nagging - so,
  # copied sources from RubyGems SVN trunk, and mixing in...
  # :-(
  # There should be a more stable integration point with RubyGems
  # Any ideas or contributions are welcome!
  def sprout_search(gem_pattern, platform_only = false)
    version_requirement = nil
    only_platform = false

    # unless Gem::Dependency === gem_pattern
    #   warn "#{Gem.location_of_caller.join ':'}:Warning: Gem::SourceIndex#search support for #{gem_pattern.class} patterns is deprecated"
    # end

    case gem_pattern
    when Regexp then
      version_requirement = platform_only || Gem::Requirement.default
    when Gem::Dependency then
      only_platform = platform_only
      version_requirement = gem_pattern.version_requirements
      gem_pattern = if Regexp === gem_pattern.name then
                      gem_pattern.name
                    elsif gem_pattern.name.empty? then
                      //
                    else
                      /^#{Regexp.escape gem_pattern.name}$/
                    end
    else
      version_requirement = platform_only || Gem::Requirement.default
      gem_pattern = /#{gem_pattern}/i
    end

    unless Gem::Requirement === version_requirement then
      version_requirement = Gem::Requirement.create version_requirement
    end

    specs = @gems.values.select do |spec|
      spec.name =~ gem_pattern and
        version_requirement.satisfied_by? spec.version
    end

    if only_platform then
      specs = specs.select do |spec|
        Gem::Platform.match spec.platform
      end
    end

    specs.sort_by { |s| s.sort_obj }
  end
end

module RubiGen # :nodoc:[all]

  class Base # :nodoc:[all]

    def initialize(runtime_args, runtime_options = {})
      @args = runtime_args
      parse!(@args, runtime_options)

      # Derive source and destination paths.
      @source_root = options[:source] || File.join(spec.path, 'templates')
      
      if options[:destination]
        @destination_root = options[:destination]
      elsif defined? Sprout::Sprout.project_path
        @destination_root = Sprout::Sprout.project_path
      else
        @destination_root = Dir.pwd
      end

      # Silence the logger if requested.
      logger.quiet = options[:quiet]

      # Raise usage error if help is requested.
      usage if options[:help]
    end

  end

  # GemGeneratorSource hits the mines to quarry for generators.  The latest versions
  # of gems named sprout-#{sprout_name}-bundle are selected.
  class GemGeneratorSource < AbstractGemSource # :nodoc:[all]
    
    def initialize(name=nil)
      super()
      @sprout_name = name
    end

    # Yield latest versions of generator gems.
    def each
      Gem::cache.sprout_search(/sprout-*#{@sprout_name}-bundle$/).inject({}) { |latest, gem|
        hem = latest[gem.name]
        latest[gem.name] = gem if hem.nil? or gem.version > hem.version
        latest
      }.values.each { |gem|
        yield Spec.new(gem.name.sub(/sprout-*#{@sprout_name}-bundle$/, ''), gem.full_gem_path, label)
      }
    end

    def each_sprout
      Gem::cache.sprout_search(/^sprout-.*/).inject({}) { |latest, gem|
        hem = latest[gem.name]
        latest[gem.name] = gem if hem.nil? or gem.version > hem.version
        latest
      }.values.each { |gem|
        yield Spec.new(gem.name, gem.full_gem_path, label)
      }
    end
  end

  # GemPathSource looks for generators within any RubyGem's 
  # /sprout/generators/<generator_name>/<generator_name>_generator.rb file.
  # It will only include generators from sprouts whose name includes
  # #{sprout_name}-bundle
  class GemPathSource < AbstractGemSource # :nodoc:[all]
    
    def initialize(name=nil)
      super()
      @sprout_name = name
    end

    # Yield each generator within generator subdirectories.
    def each
      generator_full_paths.each do |generator|
        yield Spec.new(File.basename(generator).sub(/_generator.rb$/, ''), File.dirname(generator), label)
      end
    end

    private
      def generator_full_paths
        @generator_full_paths ||=
          Gem::cache.inject({}) do |latest, name_gem|
            name, gem = name_gem
            hem = latest[gem.name]
            latest[gem.name] = gem if hem.nil? or gem.version > hem.version
            latest
          end.values.inject([]) do |mem, gem|
            Dir[gem.full_gem_path + '/lib/sprout/**/generators/**/*_generator.rb'].each do |generator|
              if(@sprout_name && gem.name.match(/sprout-#{@sprout_name}-bundle/))
                mem << generator
              end
            end
            mem
          end
      end
  end

  module Lookup # :nodoc:[all]
    module ClassMethods # :nodoc:[all]
      
      def use_sprout_sources!(sprout_name, project_path=nil)
        reset_sources

        # Project-specific generator paths
        if project_path
          sources << PathSource.new(:project, "#{project_path}/generators")
          sources << PathSource.new(:script, "#{project_path}/script/generators")
          sources << PathSource.new(:vendor, "#{project_path}/vendor/generators")
        end

        # System-wide generator paths
        system_path = "#{Sprout::Sprout.sprout_cache}/generators/#{sprout_name}"
        if(File.exists?(system_path))
          sources << PathSource.new(:system, system_path)
        end

        # Gem generators will collect all
        # rubygems that end with -bundle or -generators
        if(Object.const_defined?(:Gem))
          sources << GemGeneratorSource.new(sprout_name)
          sources << GemPathSource.new(sprout_name)
        end
      end
    end
  end

end
