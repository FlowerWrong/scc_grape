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
      if ENV['CONFIG_SERVER_URL'].blank?
        puts 'No CONFIG_SERVER_URL provided, scc_grape will not fetch config from spring cloud config server'
      elsif ENV['APP_NAME'].blank?
        puts 'No APP_NAME provided, scc_grape will not fetch config from spring cloud config server'
      else
        $cloud_env = SccRuby::Api.fetch(ENV['CONFIG_SERVER_URL'], ENV['APP_NAME'], ENV['APP_ENV'] || 'default', ENV['CLOUD_USERNAME'] || '', ENV['CLOUD_PASSWORD'] || '')
      end
    end
  end
end
