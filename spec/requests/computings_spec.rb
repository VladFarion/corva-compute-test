# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Computings', type: :request do
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

    # While this test suite might look excessive, because I don't have a change to ask questions
    # about task, I have to be prepared for worst case scenario, meaning users can input
    # whatever they want and ideally we shouldn't break with unhandled error
    context 'when params are invalid' do
      context 'when params are empty' do
        let(:params) { {} }
        let(:error_text) { 'timestamp, data is not present' }

        it_behaves_like 'request error'
      end

      context 'when params are missing titles' do
        let(:data) { [{ values: part_1_values }, { title: part_2_title, values: part_2_values }] }
        let(:error_text) { 'title is not present in one of data entries' }

        it_behaves_like 'request error'
      end

      context 'when params has titles other than "Part 1" and "Part 2"' do
        let(:part_1_title) { 'Title 1' }
        let(:part_2_title) { 'Title 2' }
        let(:error_text) { 'titles in data entries does not match "Part 1", "Part 2" pattern' }

        it_behaves_like 'request error'
      end

      context 'when params has more then two entries in data param' do
        let(:data) { [{}, {}, {}] }
        let(:error_text) { 'there are more then 2 data entries' }

        it_behaves_like 'request error'
      end

      context 'when params contain arrays of different sizes' do
        let(:part_2_values) { [] }
        let(:error_text) { 'arrays in data entries have different size. Part 1 has size 6, while part 2 has size 0' }

        it_behaves_like 'request error'
      end

      context 'when array contains not number value' do
        let(:part_2_values) { [6, 2, 3, 'test', 2, 0] }
        let(:error_text) { 'Not all values from Part 2 are numbers' }

        it_behaves_like 'request error'
      end

      context 'when arrays are too big' do
        let(:part_1_values) { Array.new(10_000_000) }
        let(:part_2_values) { Array.new(10_000_000) }
        let(:error_text) { 'Your request is too big to process. Please consider splititng it into chunks' }

        it 'returns payload too big status code' do
          make_request
          expect(response.status).to eq 413
        end

        it 'returns specific error message' do
          make_request
          expect(json_response[:error]).to eq 'Your request is too big to process. Please consider splititng it into chunks'
        end
      end
    end

    shared_examples 'correct response' do |answer|
      it 'returns success status code' do
        make_request
        expect(response.status).to eq 200
      end

      describe 'with specific response structure' do
        it 'has passed request_id' do
          expect(json_response['request_id']).to eq request_id
        end

        it 'has passed timestamp' do
          expect(json_response['timestamp']).to eq timestamp
        end

        describe 'with correct result field' do
          it 'has correct title' do
            expect(json_response['result']['title']).to eq 'Result'
          end

          it 'has correct values' do
            expect(json_response['result']['title']).to eq answer
          end
        end
      end
    end

    context 'when params are valid' do
      context 'when arrays are small' do
        it_behaves_like 'correct response', [-6, 0, 4, 3, -7, 5]
      end

      # context 'when arrays have 100_000 > size > 10_000_000' do
      #   let(:part_1_values) { Array.new(9_999_999, 2) }
      #   let(:part_2_values) { Array.new(9_999_999, 1) }
      #
      #   it_behaves_like 'correct response', values: Array.new(9_999_999, 1)
      # end
    end
  end
end
