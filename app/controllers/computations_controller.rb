# frozen_string_literal: true

class ComputationsController < ApplicationController
  def compute
    unless validation.success?
      render json: { error: validation.error }, status: :bad_request
      return
    end

    substractions_array = Compute::SubstractValues.new(computing_params['data']).perform!
    render json: ComputeSerializer.new(computing_params, substractions_array)
  end

  private

  def validation
    @validation ||= Compute::ParamsValidator.new(computing_params).validate!
  end

  def computing_params
    params.permit(:request_id, :timestamp, data: [:title, values: []])
  end
end
