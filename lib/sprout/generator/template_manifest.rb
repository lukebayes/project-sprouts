module Sprout::Generator

  class TemplateManifest < FileManifest

    protected

    def resolve_template
      generator.resolve_template read_source
    end
  end
end

