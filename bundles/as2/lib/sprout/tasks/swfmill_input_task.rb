
module Sprout

  class SWFMillInputError < StandardError #:nodoc:
  end

  # The SWFMillInputTask will generate an XML document by combining an ERB
  # template with a selected directory. The resulting XML document should
  # be appropriate as input for the SWFMill tool.
  #
  # The good news is that you should probably never need to see this task
  # since the SWFMillTask will automatically create it when that task is
  # given a directory as input.
  class SWFMillInputTask < Rake::FileTask
    DEFAULT_TEMPLATE = 'Template.erb'
    DEFAULT_INPUT_EXPR = '/**/*'

    # Directory to scan for files that get added to the template
    attr_accessor :input
    # ERB template that will be used to generate the output xml
    attr_writer   :template
    # Blob or expression that will be used to find files to include
    attr_writer   :input_expr

    def self.define_task(args, &block) # :nodoc:
      t = super
      yield t if block_given?
      t.define(args, &block)
    end

    def define(args, &block) # :nodoc:
      @input_files = FileList[input + input_expr]
      file template

      file @input_files
      prerequisites << @input_files
      prerequisites << template
      
      CLEAN.add output
    end
    
    def execute(*args) # :nodoc:
      ensure_template
      resolve_template(template, output, @input_files, input)
    end

    # The output XML document to generate. This should be appropriate
    # input for the SWFMillTask.
    def output=(output)
      @output = output
    end
    
    def output # :nodoc:
      @output ||= name.to_s
    end
    
    def input_expr # :nodoc:
      @input_expr ||= DEFAULT_INPUT_EXPR
    end
    
    def template # :nodoc:
      @template ||= default_template
    end
    
    private
    
    def default_template
      return File.join(File.dirname(input), DEFAULT_TEMPLATE)
    end
    
    def ensure_template
      return if(template && File.exists?(template))
      File.open(template, 'wb') do |f|
        f.write(template_content)
      end
    end
    
#    def create_output
#       File.join(File.dirname(input), File.basename(input).capitalize + ".xml")
#   end

    def resolve_template(template, output, files, base_dir)
      SWFMillInputResolver.new(template, output, files, base_dir)
      Log.puts ">> Created file at: #{output}"
    end
    
    def template_content
      return <<EOF
<?xml version="1.0" encoding="iso-8859-1" ?>
<%= xml_edit_warning %>
<movie width="600" height="450" framerate="24" version="8">
  <background color="#ffffff"/>
  <frame>
    <library>
<% files.each do |file| if(!ignore_file?(file) && !File.directory?(file)) %>
      <clip id="<%=get_symbol_id(file)%>" import="<%=file%>" />
<% end end %>

    </library>
  </frame>
  <frame>
    <stop />
  </frame>
</movie>
EOF
    end
  end

  class SWFMillInputResolver < SimpleResolver #:nodoc:
  
    def ignore_file?(file)
      base = File.basename(file)
      if(base == '.DS_Store' || base == 'Thumbs.db' || base.match(/^\d/) || base == '.svn')
        @ignored_files << file
        return true
      end
      return false
    end
  
    def get_symbol_id(file)
      trimmed = file.gsub(@base_dir, '')
      parts = trimmed.split('.')
      parts.pop
      trimmed = parts.join('.')

      result = trimmed.split(File::SEPARATOR).join('.')
      result = result.gsub(/^./, '')
      return result
    end
  end
end

def swfmill_input(args, &block)
  Sprout::SWFMillInputTask.define_task(args, &block)
end  
