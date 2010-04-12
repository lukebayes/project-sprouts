
class FakeProcessRunner

  attr_accessor :command

  def execute_open4 *command
    @command = command
    @r = FakeIO.new command
    @w = FakeIO.new command
    @e = FakeIO.new command
  end

  def read
    @r
  end

  def write value
    @w.write value
  end

  def read_err
    @e
  end

end

