require 'sprout'
sprout 'as3'

mxmlc :compile do |t|
  t.debug = true
  t.input = 'SomeProject.as'
  t.output = 'SomeProject-debug.swf'
end