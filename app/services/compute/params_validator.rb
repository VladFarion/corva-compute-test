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

    def initialize(params)
      @params = params
    end

    def validate!
      check_schema || check_size_limit || check_arrays_length_equality || Result.new(true, nil)
    end

    private

    def check_schema
      return if JSON::Validator.validate(SCHEMA, params.to_h)

      failure(I18n.t('compute.params.errors.schema_not_valid'))
    end

    def check_size_limit
      return if params['data'][0]['values'].length < 100_000

      failure(I18n.t('compute.params.errors.size_limit_too_big'))
    end

    def check_arrays_length_equality
      left_values_size = params['data'][0]['values'].size
      right_values_size = params['data'][1]['values'].size
      return if left_values_size == right_values_size

      failure(I18n.t('compute.params.errors.data_arrays_not_equal', left_values_size: left_values_size, right_values_size: right_values_size))
    end

    def failure(reason)
      Result.new(false, reason)
    end
  end
end
