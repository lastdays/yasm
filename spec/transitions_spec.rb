require 'spec_helper'

RSpec.describe Yasm::Transitions do
  describe 'instance behavior' do
    describe '#intialize' do
      context 'when argumnet is array' do
        let(:arg) { [1,2,3] }

        it 'initialize' do
          obj = described_class.new(arg)
          expect(obj.data).to match_array([1,2,3])
        end
      end

      context 'when argumnet is not array' do
        let(:arg) { 2 }

        it { expect { described_class.new(arg) }.to raise_error }
      end
    end

    describe '#push' do
      context 'when argumnet is Transition' do
        let(:arg) { Yasm::Transition.new(from: :foo, to: :bar) }

        it 'initialize' do
          obj = described_class.new([])
          obj.push(arg)
          expect(obj.data).to eq([arg])
        end
      end

      context 'when argumnet is not array' do
        let(:arg) { 2 }

        it { expect { described_class.new(arg) }.to raise_error }
      end
    end    
  end
end