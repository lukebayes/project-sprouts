
class FakeIO

  def initialize(value="")
    @value = value
  end

  def read
    @value
  end

  def write value
    read << value
  end

  def size
    read.size
  end

  def to_s
    read
  end

end

