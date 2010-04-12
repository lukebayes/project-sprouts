
class FakeProcessRunner

  attr_accessor :command

  def execute_open4 *command
    @command = command
    @r = FakeIO.new
    @w = FakeIO.new
    @e = FakeIO.new
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

