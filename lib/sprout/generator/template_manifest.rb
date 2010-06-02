module Sprout::Generator

  class TemplateManifest < FileManifest

    protected

    def resolve_template
      template_content = read_source
      generator.resolve_template template_content
    end
  end
end

