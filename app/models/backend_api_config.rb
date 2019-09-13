# frozen_string_literal: true

class BackendApiConfig < ApplicationRecord

  default_scope -> { order(id: :asc) }
  belongs_to :service, inverse_of: :backend_api_configs
  belongs_to :backend_api, inverse_of: :backend_api_configs

  has_many :backend_api_metrics, through: :backend_api, source: :metrics

  validates :path, length: { in: 0..255, allow_nil: false }, path: true

  after_create do
    backend_api.metrics.each { |metric| metric.send(:sync_backend) }
  end

  scope :with_subpath, (lambda do
    common_query = where.not(path: '/')
    System::Database.oracle? ? common_query.where('path is NOT NULL') : common_query.where.not(path: '')
  end)

  delegate :private_endpoint, to: :backend_api

  def path=(value)
    super(StringUtils::StripSlash.strip_slash(value))
  end
end
