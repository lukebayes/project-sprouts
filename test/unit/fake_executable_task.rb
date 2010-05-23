
class FakeExecutableTask
  attr_accessor :name
  attr_accessor :default_prefix
  attr_accessor :default_short_prefix

  def initialize
    super
    @name = 'fake_tool'
    @default_prefix = '-'
    @default_short_prefix = '--'
  end

  def default_file_expression
    @default_file_expression ||= '/**/**/*'
  end

  def prerequisites
    @prerequisites ||= []
  end
end

