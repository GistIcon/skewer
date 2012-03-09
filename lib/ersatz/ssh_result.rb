module Skewer
  # fakes a fog SSH result
  class ErsatzSSHResult
    attr_accessor :command, :stdout, :status

    def initialize(command, stdout, status)
      @command = command
      @stdout = stdout
      @status = status
      Skewer.logger.debug self.stdout
    end
  end
end
