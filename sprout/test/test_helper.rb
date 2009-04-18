require 'test/unit'
$:.push(File.dirname(__FILE__) + '/../lib')
$:.push(File.dirname(__FILE__))

require File.dirname(__FILE__) + '/../lib/sprout'
require 'sprout_test_case'
require 'generator_test_helper'

Sprout::Log.debug = true
ProgressBar.debug = true
