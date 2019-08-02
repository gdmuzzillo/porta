require 'test_helper'
require 'three_scale/sidekiq_logging_middleware'

class SidekiqLoggingMiddlewareTest < ActiveSupport::TestCase
  test 'filter sensitive arguments' do
    middleware = ThreeScale::SidekiqLoggingMiddleware.new
    msg = {
      'jid' => 123,
      'args' => [
        {
          "some_arg": "value",
          "user_key": "secret_value"
        }
      ]
    }

    Rails.logger.expects(:info).with('Enqueued DummyWorker#123 with args: [{:some_arg=>"value", :user_key=>"[FILTERED]"}]')

    middleware.call('DummyWorker', msg) { nil }
  end
end
