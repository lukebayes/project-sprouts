module Sprout::Generator
  class FileManifest < Manifest
    attr_accessor :template
    attr_accessor :templates

    def create
      File.open path, 'w+' do |file|
        file.write resolve_template
      end
      say "Created file:      #{path}"
    end

    def destroy
      expected_content = resolve_template
      actual_content = File.read path
      if generator.force || actual_content == expected_content
        FileUtils.rm path
        say "Removed file: #{path}"
        true
      else
        say "Skipped remove file: #{path}"
        false
      end
    end

    private

    def resolve_template
      template_content = read_template
      generator.resolve_template template_content
    end

    def read_template
      templates.each do |template_path|
        path = File.join template_path, template_name
        if File.exists?(path)
          return File.read path
        end
      end
      raise Sprout::Errors::MissingTemplateError.new "Could not find template (#{template_name}) in any of (#{templates.inspect})"
    end

    def template_name
      template || File.basename(path)
    end
  end
end

