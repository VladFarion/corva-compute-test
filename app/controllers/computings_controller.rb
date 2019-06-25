# frozen_string_literal: true

class ComputingsController < ApplicationController
  def compute
    unless validation.success?
      render json: { error: validation.error }, status: :bad_request
      return
    end

    render json: {
      request_id: computing_params[:request_id].to_i,
      timestamp: computing_params[:timestamp],
      result: { title: 'Result', values: calculate_answer }
    }, status: 200
  end

  def calculate_answer
    first_array = computing_params['data'][0]['values']
    second_array = computing_params['data'][1]['values']
    first_array.each.with_index do |first_arr_elem, index|
      value_to_substract = second_array[index]
      first_array[index] = first_arr_elem - value_to_substract
    end
  end

  def validation
    @validation_result ||= Compute::ParamsValidator.new(computing_params).validate!
  end

  def computing_params
    params.permit(:request_id, :timestamp, data: [:title, values: []])
  end
end
