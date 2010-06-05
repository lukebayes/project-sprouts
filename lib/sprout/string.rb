
class String

   # "FooBar".snake_case #=> "foo_bar"
   def snake_case
     gsub(/\B[A-Z]/, '_\&').downcase
   end

   # "foo_bar".camel_case #=> "FooBar"
   def camel_case
     str = gsub(/^[a-z]|_+[a-z]/) { |a| a.upcase }
     str.gsub(/_/, '')
   end
end

