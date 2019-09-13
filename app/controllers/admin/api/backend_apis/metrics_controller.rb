# frozen_string_literal: true

class Admin::Api::BackendApis::MetricsController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  representer Metric

  # TODO: paginate or no need?
  # TODO: ApiDocs :) and only when the RU is enabled
  def index
    # TODO: top_level_metrics or all? nested?
    respond_with(backend_api.metrics)
  end

  # TODO: ApiDocs :) and only when the RU is enabled
  def show
    respond_with(metric)
  end

  # TODO: ApiDocs :) and only when the RU is enabled
  def create
    respond_with(backend_api.metrics.create(metric_params))
  end

  # TODO: ApiDocs :) and only when the RU is enabled
  def update
    metric.update(metric_params)
    respond_with(metric)
  end

  # TODO: ApiDocs :) and only when the RU is enabled
  def destroy
    metric.destroy
    respond_with(metric)
  end

  private

  def authorize
    authorize! :manage, BackendApi
  end

  def metric
    @metric ||= backend_api.metrics.find(params[:id])
  end

  def backend_api
    @backend_api ||= current_account.backend_apis.find(params[:backend_api_id]) # TODO: only the accessible backend apis once #1144 is merged
  end

  def metric_params
    params.require(:metric).permit(:friendly_name, :system_name, :unit, :description) # TODO: careful with the system name!!
  end
end
