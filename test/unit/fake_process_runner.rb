
class FakeProcessRunner

  attr_accessor :command

  def initialize
    @r = FakeIO.new
    @w = FakeIO.new
    @e = FakeIO.new
  end

  def execute_open4 *command
    @command = command
  end

  def read
    @r
  end

  def read_err
    @e
  end

  def write value
    @w.write value
  end

end

