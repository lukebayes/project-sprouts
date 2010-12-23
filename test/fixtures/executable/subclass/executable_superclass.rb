
class ExecutableSuperclass < Sprout::Executable::Base

  set :default_prefix, '---'

  add_param :superclass_param, String
end

