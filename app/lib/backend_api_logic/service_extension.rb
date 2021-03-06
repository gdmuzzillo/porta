# frozen_string_literal: true

module BackendApiLogic
  module ServiceExtension
    extend ActiveSupport::Concern

    included do
      has_many :backend_api_configs, inverse_of: :service, dependent: :destroy
      has_many :backend_apis, through: :backend_api_configs

      alias_method :backend_api, :first_backend_api

      has_many :backend_api_metrics, through: :backend_api_configs

      has_many :all_metrics, ->(object) do
        unscope(:where).where('(owner_type = ? AND owner_id = ?) OR (owner_type = ? AND owner_id IN (?))', 'Service', object.id, 'BackendApi', object.backend_apis.pluck(:id))
      end, class_name: 'Metric'
    end

    def first_backend_api
      @backend_api ||= find_or_create_first_backend_api!
    end

    def find_or_create_first_backend_api!
      return unless account
      config = backend_api_configs.first || create_first_backend_api_config!
      config.backend_api
    end

    private

    def create_first_backend_api_config!
      backend_api = account.backend_apis.build(
        system_name: system_name,
        name: "#{name} Backend API",
        description: "Backend API of #{name}",
        private_endpoint: proxy&.[]('api_backend')
      )
      constructor = new_record? ? :build : :create!
      attrs = {backend_api: backend_api, path: ''}
      backend_api_configs.public_send(constructor, attrs)
    end
  end
end
