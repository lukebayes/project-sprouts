
class FakeIO

  def initialize(value=nil)
    @value = value || ""
  end

  def read
    @value || ""
  end

  def write value
    @value << value
  end

  def size
    read.size
  end

end

