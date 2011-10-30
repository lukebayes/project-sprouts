require 'rdoc/rdoc'

module Sprout

  class RDocParser

    def parse content
    end

    def parse_from_caller_string caller_string
      class_name, file_name, line_number = parse_caller_string caller_string
      rdoc_description_for class_name, file_name, line_number
    end

    private

    ##
    # NOTE: Don't forget that this string *sometimes* contains a colon on Windows...
    def parse_caller_string caller_string
      sections = caller_string.split(' ')
      parts = sections.first.split(':')
      file_name   = parts.shift
      line_number = parts.shift
      class_name  = class_name_from_caller_string caller_string
      #puts ">> class_name: #{class_name} file_name: #{file_name} line_number: #{line_number}"
      [class_name, file_name, line_number]
    end

    def class_name_from_caller_string caller_string
      parts   = caller_string.split(' ')
      long    = parts.pop
      matched = long.match /<class:([\w:]+)>/
      matched[1] unless matched.nil?
    end

    def rdoc_description_for class_name, file_name, line_number
      rendered = rendered_rdoc file_name
    end

    def rendered_rdoc file
      @rendered_rdoc ||= render_rdoc file
    end

    def render_rdoc file
      rdoc = RDoc::RDoc.new
      puts "==================================="
      puts ">> generating rdoc for: #{file}"

      rdoc.document [ file, "--format=xml", "--output=temp" ]
      {}
    end

    def render_rdoc_from_files
      # This works to some extent...
      #rdoc test/fixtures/examples/echo_inputs.rb --fmt=xml --op=tmp --all -q
      # But the following does not do the same thing:
      #response = rdoc.document [ file, '--fmt=xml', '--op=tmp', '--all', '-q' ]

      options           = RDoc::Options.new
      options.files     = FileList[ file ]
      options.formatter = 'markup'
      options.op_dir    = './tmp'
      options.verbosity = 0

      rdoc.options      = options

      #rdoc.stats        = RDoc::Stats.new 1, options.verbosity
      #response = rdoc.document []

      response = rdoc.parse_files [ file ]
      render_rdoc_toplevel response
    end

    def render_rdoc_toplevel toplevel
      puts ">> toplevel: #{toplevel}"
      toplevel.each do |file|
        puts ">> file: #{file.name}"
        puts ">> pretty: #{file.pretty_print}"
      end

      toplevel
    end

    def render_rdoc_bak file
      rdoc = RDoc::RDoc.new
      rdoc.options = RDoc::Options.new
      rdoc.parse_files [file]
    end
  end
end

