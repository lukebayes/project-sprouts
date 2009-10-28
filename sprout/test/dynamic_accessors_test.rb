require File.dirname(__FILE__) + '/test_helper'

class DyanamicAccessorsTest <  Test::Unit::TestCase
  
  def test_string
    instance = Dynamo.new
    instance.prop = 'bar'
    assert_equal 'bar', instance.prop
  end
  
  def test_number
    instance = Dynamo.new
    instance.prop = 100
    assert_equal 100, instance.prop
  end
  
  def test_hash
    instance = Dynamo.new
    instance.prop = {
      :name => 'hello'
    }
    assert_equal 'hello', instance.prop[:name]
  end
  
  def test_array
    instance = Dynamo.new
    instance.prop = ['hello']
    assert_equal 'hello', instance.prop[0]
  end
end

class Dynamo
  include DynamicAccessors
end
