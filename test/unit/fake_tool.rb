
class FakeToolTask
  attr_accessor :name

  def initialize
    super
    @name = 'fake_tool'
  end

  def default_file_expression
    @default_file_expression ||= '/**/**/*'
  end

  def prerequisites
    @prerequisites ||= []
  end
end

