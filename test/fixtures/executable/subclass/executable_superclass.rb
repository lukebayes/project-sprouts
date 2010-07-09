
class ExecutableSuperclass
  include Sprout::Executable

  set :default_prefix, '---'

  add_param :superclass_param, String
end

