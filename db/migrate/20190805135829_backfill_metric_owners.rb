require 'progress_counter'

class BackfillMetricOwners < ActiveRecord::Migration
  def up
    say_with_time 'Updating metric owners...' do
      Metric.reset_column_information
      progress = ProgressCounter.new(Metric.count)
      Metric.find_each do |metric|
        metric.update_columns(owner_id: metric.service_id, owner_type: 'Service') unless metric.owner_type?
        progress.call
      end
    end
  end
end
