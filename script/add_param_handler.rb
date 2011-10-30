
class AddParamHandler < YARD::Handlers::Ruby::MethodHandler

  handles method_call(:add_param)

  def process
    name = statement[1][0].source.gsub(/^:/, '')
    class_name = statement[1][1].source

    case class_name
      when "Strings"
        class_name = "Array<String>"
      when "Files"
        class_name = "Array<String> [Files]"
      when "Paths"
        class_name = "Array<String> [Paths]"
      when "Urls"
        class_name = "Array<String> [Urls]"
    end

    namespace.attributes[scope][name] ||= SymbolHash[:read => nil, :write => nil]

    {:read => name, :write => "#{name}="}.each do |type, meth|
        namespace.attributes[scope][name][type] = MethodObject.new(namespace, meth, scope) do |o|

          o.source = statement.source
          o.signature = method_signature(meth)
          o.docstring = statement.comments

          if type == :write
            o.parameters = [['value', nil]]
          else
            new_tag = YARD::Tags::Tag.new(:return, "An instance of #{class_name}", class_name)
            o.docstring.add_tag(new_tag)
          end

          o.visibility = visibility
        end
    end
  end

end

