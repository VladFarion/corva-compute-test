# freeze_string_literal: true

module Compute
  class ParamsValidator
    Result = Struct.new(:success?, :error)
    SCHEMA = {
      type: 'object',
      required: ['timestamp', 'data'],
      properties: {
        timestamp: {
          type: 'integer',
        },
        data: {
          type: 'array',
          maxItems: 2,
          items: {
            type: 'object',
            required: ['title', 'values'],
            properties: {
              title: {
                type: 'string'
              },
              values: {
                type: 'array',
                items: {
                  type: 'number'
                }
              }
            }
          }
        }
      }
    }

    attr_reader :params
    attr_accessor :result

    def initialize(params)
      @params = params
      @result = Result.new(true, nil)
    end

    def validate!
      result = check_schema
      result = check_size_limit if result.success?
      result = check_arrays_length_equality if result.success?
      result
    end

    private

    def check_schema
      return result if JSON::Validator.validate(SCHEMA, params.to_h)

      Result.new(false, 'data is not present or valid')
    end

    def check_size_limit
      return result if params['data'][0]['values'].length < 100_000

      Result.new(false, 'Your request is too big to process. Please consider splititng it into chunks')
    end

    def check_arrays_length_equality
      first_array_length = params['data'][0]['values'].length
      second_array_length = params['data'][1]['values'].length
      return result if first_array_length == second_array_length

      Result.new(false, "arrays in data entries have different size. Part 1 has size #{first_array_length}, while part 2 has size #{second_array_length}")
    end
  end
end
