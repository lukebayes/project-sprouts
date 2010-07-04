
class ExecutableSubclass < ExecutableSuperclass
  include Sprout::Executable

  add_param :subclass_param, String
end

