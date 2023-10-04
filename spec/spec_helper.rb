require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidekiq/batch'

redis_opts = { url: "redis://127.0.0.1:6379/2" }

Sidekiq.configure_client do |config|
  config.redis = redis_opts
end

Sidekiq.configure_server do |config|
  config.redis = redis_opts
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.around(:each) do |example|
    with_clean_redis do
      example.run
    end
  end

  def with_clean_redis
    Sidekiq.redis do |r|
      r.flushdb
      begin
        yield
      ensure
        r.flushdb
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }
