# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Computations', type: :request do
  describe '/compute/:request_id' do
    subject(:make_request) { post "/compute/#{request_id}", params: params, as: :json }

    let(:request_id) { 123 }
    let(:part_1_title) { 'Part 1' }
    let(:part_2_title) { 'Part 2' }
    let(:part_1_values) { [0, 3, 5, 6, 2, 9] }
    let(:part_2_values) { [6, 3, 1, 3, 9, 4] }
    let(:timestamp) { 123456789 }

    let(:params) do
      {
        timestamp: timestamp,
        data: data,
      }
    end
    let(:data) do
      [
        { title: part_1_title, values: part_1_values },
        { title: part_2_title, values: part_2_values },
      ]
    end

    shared_examples 'request error' do
      it 'returns bad request status' do
        make_request
        expect(response.status).to eq 400
      end

      it 'returns specific error message' do
        make_request
        expect(json_response['error']).to eq error_text
      end
    end

    context 'when params are invalid' do
      let(:error_text) { 'data is not present or valid' }

      context 'when params are empty' do
        let(:params) { {} }

        it_behaves_like 'request error'
      end

      context 'when params are missing titles' do
        let(:data) { [{ values: part_1_values }, { title: part_2_title, values: part_2_values }] }

        it_behaves_like 'request error'
      end

      context 'when params has more then two entries in data param' do
        let(:data) { [{}, {}, {}] }

        it_behaves_like 'request error'
      end

      context 'when params contain arrays of different sizes' do
        let(:part_2_values) { [1] }
        let(:error_text) { 'arrays in data entries have different size. Part 1 has size 6, while part 2 has size 1' }

        it_behaves_like 'request error'
      end

      context 'when array contains not number value' do
        let(:part_2_values) { [6, 2, 3, 'test', 2, 0] }

        it_behaves_like 'request error'
      end

      context 'when arrays are too big' do
        let(:part_1_values) { Array.new(100_000, 2) }
        let(:part_2_values) { Array.new(100_000, 1) }
        let(:error_text) { 'Your request is too big to process. Please consider splititng it into chunks' }

        it_behaves_like 'request error'
      end
    end

    shared_examples 'correct response' do |answer|
      # For performance reasons of specs, all of these checks are in single spec
      it 'returns success status code and has specific response structure' do # rubocop:disable  Metics/LineLength, RSpec/ExampleLength, RSpec/MultipleExpectations
        make_request
        expect(response.status).to eq 200
        expect(json_response['request_id']).to eq request_id
        expect(json_response['timestamp']).to eq timestamp
        expect(json_response['result']['title']).to eq 'Result'
        expect(json_response['result']['values']).to eq answer
      end
    end

    context 'when params are valid' do
      context 'when arrays are small' do
        it_behaves_like 'correct response', [-6, 0, 4, 3, -7, 5]
      end

      context 'when arrays have big size' do
        let(:part_1_values) { Array.new(99_999, 3) }
        let(:part_2_values) { Array.new(99_999, 2) }

        it_behaves_like 'correct response', Array.new(99_999, 1)
      end
    end
  end
end
