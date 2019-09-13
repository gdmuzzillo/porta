# frozen_string_literal: true

require 'test_helper'

class Admin::API::BackendApis::MetricsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    host! @tenant.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
    @backend_api = FactoryBot.create(:backend_api, account: @tenant)
  end

  attr_reader :backend_api, :access_token_value, :tenant

  test 'index' do
    FactoryBot.create_list(:metric, 2, owner: backend_api)
    FactoryBot.create(:metric, owner: FactoryBot.create(:backend_api, account: tenant))
    FactoryBot.create(:metric, service: FactoryBot.create(:service, account: tenant))

    get admin_api_backend_api_metrics_path(backend_api_id: backend_api.id, access_token: access_token_value)

    assert_response :success
    assert(response_collection_metrics_of_backend_api = JSON.parse(response.body)['metrics'])
    assert_equal backend_api.metrics.count, response_collection_metrics_of_backend_api.length
    response_collection_metrics_of_backend_api.each do |response_metric|
      assert backend_api.metrics.find_by(id: response_metric.dig('metric', 'id'))
    end
  end

  test 'show' do
    get admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id)

    assert_response :success
    assert_equal metric.id, JSON.parse(response.body).dig('metric', 'id')
  end

  test 'create' do
    assert_difference(Metric.method(:count)) do
      post admin_api_backend_api_metrics_path(backend_api_id: backend_api.id, access_token: access_token_value), { friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :created
    end
    assert(@metric = backend_api.metrics.find_by(id: JSON.parse(response.body).dig('metric', 'id')))
    assert_equal 'metric friendly name', metric.friendly_name
    assert_equal 'hit', metric.unit
  end

  test 'create with errors in the model' do
    post admin_api_backend_api_metrics_path(backend_api_id: backend_api.id, access_token: access_token_value), { friendly_name: '', unit: 'hit' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
  end

  test 'update' do
    put admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id), { friendly_name: 'metric friendly name', unit: 'hit' }
    assert_response :success
    metric.reload
    assert_equal 'metric friendly name', metric.friendly_name
    assert_equal 'hit', metric.unit
  end

  test 'update with errors in the model' do
    put admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id), { friendly_name: '' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
  end

  test 'destroy' do
    @metric = FactoryBot.create(:metric, owner: backend_api)
    assert_difference(Metric.method(:count), -1) do
      delete admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id)
      assert_response :success
    end
    assert_raises(ActiveRecord::RecordNotFound) { metric.reload }
  end

  test 'without permission' do
    member = FactoryBot.create(:member, account: tenant)
    access_token_value = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw').value

    get admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id)
    assert_response :forbidden

    delete admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id)
    assert_response :forbidden

    put admin_api_backend_api_metric_path(backend_api_id: backend_api.id, access_token: access_token_value, id: metric.id), { friendly_name: 'metric friendly name', unit: 'hit' }
    assert_response :forbidden

    post admin_api_backend_api_metrics_path(backend_api_id: backend_api.id, access_token: access_token_value), { friendly_name: 'metric friendly name', unit: 'hit' }
    assert_response :forbidden

    get admin_api_backend_api_metrics_path(backend_api_id: backend_api.id, access_token: access_token_value)
    assert_response :forbidden
  end

  private

  def metric
    @metric ||= FactoryBot.create(:metric, owner: backend_api)
  end
end