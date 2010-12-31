module Sprout::Generator

  class FileManifest < Manifest
    attr_accessor :template
    attr_accessor :templates

    def create
      content = resolve_template

      if File.exists?(path)
        if generator.force
          write_file path, content
          say "Replaced file:     #{path}"
          true
        else
          say "Skipped file:      #{path}"
          false
        end
      else
        write_file path, content
        say "Created file:      #{path}"
        true
      end
    end

    def destroy
      if !File.exists?(path)
        say "Skipped remove missing file: #{path}"
        return true
      end
      expected_content = resolve_template
      actual_content = File.read path
      if generator.force || actual_content == expected_content
        FileUtils.rm path
        say "Removed file:                #{path}"
        true
      else
        say "Skipped remove file:         #{path}"
        false
      end
    end

    protected

    def write_file path, content
      File.open path, 'w+' do |file|
        file.write content
      end
    end

    def resolve_template
      read_source
    end

    def read_source
      templates.each do |template_path|
        path = File.join template_path, source_name
        if File.exists?(path)
          return File.read path
        end
      end
      raise Sprout::Errors::MissingTemplateError.new "Could not find template (#{source_name}) in any of the following paths:\n\n    (#{templates.inspect})\n\n"
    end

    def source_name
      template || File.basename(path)
    end
  end
end

