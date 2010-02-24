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
  
  def test_each_attribute
    instance = Dynamo.new
    instance.prop_a = 'a'
    instance.prop_b = 'b'
    instance.prop_c = 'c'
    expected_keys = [:prop_a, :prop_b, :prop_c]
    expected_values = ['a', 'b', 'c']
    found_keys = []
    found_values = []
    instance.each_attribute do |key, value|
      found_keys << key
      found_values << value
    end
    sorted_keys = found_keys.collect { |item| item.to_s }.sort.collect { |item| item.to_sym }
    assert_equal expected_keys, sorted_keys
    assert_equal expected_values, found_values.sort
  end
end

class Dynamo
  include DynamicAccessors
end
