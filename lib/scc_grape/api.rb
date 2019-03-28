require 'grape'
require 'scc_ruby'

module SccGrape
  class API < Grape::API

    http_basic do |username, password|
      { ENV['SCC_USERNAME'] => ENV['SCC_PASSWORD'] }[username] == password
    end

    get :refresh do
      SccGrape::API.reload_config
      API.logger.info '$cloud_env has been reloaded from spring cloud config server'
      { msg: 'ok' }
    rescue Exception => e
      API.logger.error e.message
      error!({ msg: e.message }, 500)
    end

    def self.reload_config
      $cloud_env = SccRuby::Api.fetch(ENV['CONFIG_SERVER_URL'], ENV['APP_NAME'], ENV['APP_ENV'])
    end
  end
end
