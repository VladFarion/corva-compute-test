# frozen_string_literal: true

class ComputeSerializer
  attr_reader :request_id, :timestamp, :compute_result

  def initialize(params, values)
    @request_id = params[:request_id].to_i
    @timestamp = params[:timestamp]
    @compute_result = values
  end

  def to_json(_)
    {
      request_id: request_id,
      timestamp: timestamp,
      result: { title: 'Result', values: compute_result }
    }.to_json
  end
end
