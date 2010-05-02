
class FakeTool
  attr_accessor :name

  def initialize
    super
    @name = 'fake_tool'
  end

  def prerequisites
    @prerequisites ||= []
  end
end

