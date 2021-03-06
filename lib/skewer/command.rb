module Skewer
  # the real Command objects inherit from this
  require 'skewer'
  class SkewerCommand
    include Skewer

    def initialize(global, local)
      config.slurp_options(global.merge(local))
    end

    def is_option_boolean?(option)
      unless [true, false].include?(@global_options[option])
        return false, "Sorry, that's a bad value of '#{option}''"
      end
    end
  end
end