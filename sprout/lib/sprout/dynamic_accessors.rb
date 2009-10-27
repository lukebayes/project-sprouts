
# DynamicAccessors provides support for
# simply setting and getting values of any kind from
# any object that includes it.
#
#   require 'dynamic_accessors'
#
#   class Foo
#     include DynamicAccessors
#   end
#
#   foo = Foo.new
#   foo.bar = "Hello World"
#   foo.friends = ['a', 'b', 'c']
#   puts "foo.bar: #{foo.bar}"
#   puts "foo.friends: #{foo.friends.join(', ')}"

module DynamicAccessors
  
  def initialize(*params)
    super
    @missing_params_hash = Hash.new
  end

  def method_missing(method, *params, &block)
    if(method.to_s.match(/=$/))
      method = method.to_s.gsub('=', '').to_sym
      return @missing_params_hash[method] = params.shift
    else
      return @missing_params_hash[method] if @missing_params_hash.keys.collect(&:to_sym).include?(method)
    end
    super
  end
end
