# frozen_string_literal: true

module ApiHelper
  # Don't add rescue here. Since it's for test purposes, it's preferrable to explicitly know
  # if in some test invalid JSON response is generating
  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelper
end
