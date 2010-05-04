
class String

   # "FooBar".snake_case #=> "foo_bar"
   def snake_case
     gsub(/\B[A-Z]/, '_\&').downcase
   end

   def camel_case
     str = gsub(/^[a-z]|_+[a-z]/) { |a| a.upcase }
     str.gsub(/_/, '')
   end
end

