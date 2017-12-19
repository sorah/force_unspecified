require "force_unspecified/version"
require "force_unspecified/app"

module ForceUnspecified
  def self.call(env)
    App.call(env)
  end
end
