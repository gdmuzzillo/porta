# frozen_string_literal: true

# This class handles the creation of a Service with a Backend API attached to it if informed. It can attach an already
# existent Backend API or build a new one. It will only attach/create the Backend API if the Account is in
# the api_as_product Rolling Update.
#
class CreateServiceWithBackendApi
  def initialize(service:, backend_api_id:)
    @backend_api_id = backend_api_id
    @service        = service
    @account        = service.account
  end

  def call
    build_backend_api if @account.provider_can_use?(:api_as_product)
    @service.save
  end

  private

  def build_backend_api
    return unless @backend_api_id

    backend_api = @account.backend_apis.find(@backend_api_id)
    @service.backend_api_configs = [BackendApiConfig.new(backend_api: backend_api)]
  end
end