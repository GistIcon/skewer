class ErsatzSSHResult
  attr_accessor :command, :stdout, :status
  def initialize(command, stdout, status)
    @command = command
    @stdout = stdout
    @status = status
  end


end
