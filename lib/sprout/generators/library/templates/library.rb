require 'sprout'

module <%= input.camel_case %> 
  NAME    = '<%= input.snake_case %>'
  VERSION = '<%= version %>'
end

Sprout::Specification.new do |s|
  s.name    = <%= input.camel_case %>::NAME
  s.version = <%= input.camel_case %>::VERSION
  s.add_file_target do |f|
    f.add_library :swc, 'bin/<%= input.camel_case %>-<%= version %>.swc'
    f.add_library :src, 'src'
  end
end
