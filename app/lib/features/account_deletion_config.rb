# frozen_string_literal: true

module Features
  class AccountDeletionConfig < FeatureBase
    def initialize(config = {})
      @config = ActiveSupport::OrderedOptions.new.merge((config.presence || {}).symbolize_keys)
    end

    attr_reader :config
  end
end
