require 'test_helper'

class CreateServiceWithBackendApiTest < ActiveSupport::TestCase
  test 'should not create any backend api if backend_api is not sent' do
    backend_api_id    = nil
    service           = FactoryBot.build(:service)
    create_service    = CreateServiceWithBackendApi.new(service: service, backend_api_id: backend_api_id)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
    end
  end

  test 'should associate the same backend api if backend_api option is an id and it belongs to the same account' do
    account        = FactoryBot.create(:account)
    backend_api_id = FactoryBot.create(:backend_api, account: account).id
    service        = FactoryBot.build(:service, account: account)
    create_service = CreateServiceWithBackendApi.new(service: service, backend_api_id: backend_api_id)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
      assert_equal backend_api_id, Service.last.backend_api.id
    end
  end

  test 'should raise an error if trying to associate a backend api that belongs to another account' do
    account         = FactoryBot.create(:account)
    another_account = FactoryBot.create(:account)
    backend_api_id  = FactoryBot.create(:backend_api, account: another_account).id
    service         = FactoryBot.build(:service, account: account)
    create_service  = CreateServiceWithBackendApi.new(service: service, backend_api_id: backend_api_id)

    assert_raise(ActiveRecord::RecordNotFound) do
      create_service.call
    end
  end

  test 'should not associate the backend api if account is not in the rolling update' do
    Account.any_instance.stubs(:provider_can_use?).returns(false).at_least_once
    service        = FactoryBot.build(:service)
    account        = FactoryBot.build(:account)
    backend_api_id = FactoryBot.create(:backend_api, account: account).id
    create_service = CreateServiceWithBackendApi.new(service: service, backend_api_id: backend_api_id)

    assert_change of: -> { BackendApi.count }, by: 0 do
      saved = create_service.call

      assert saved
      assert_nil Service.last.backend_api
    end
  end
end
