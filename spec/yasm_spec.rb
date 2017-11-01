require "spec_helper"

RSpec.describe Yasm do
  let!(:klass) do
    Class.new do
      include Yasm
    end
  end

  context 'class methods' do
    context 'available methods' do
      subject { klass }

      it { is_expected.to respond_to(:state_machine) }
      it { is_expected.to respond_to(:state) }
      it { is_expected.to respond_to(:event) }
    end

    describe '.state' do
      context 'valid params' do
        context 'desclaring context' do
          context 'single parameter' do
            subject { klass.__states__ }

            before do
              klass.class_eval do
                state_machine do
                  state :first
                end
              end
            end

            it { is_expected.to eq([:first]) }
            it { expect(klass.__initial__).to eq(:first) }
          end

          context 'several parameters' do
            before do
              klass.class_eval do
                state_machine do
                  state :first, initial: true
                  state :second, :third
                end
              end
            end

            context 'class level behavior' do
              subject { klass.__states__ }

              it { is_expected.to match_array([:first, :second, :third]) }
              it { expect(klass.__initial__).to eq(:first) }
            end

            context 'instance level behavior' do
              subject { klass.new }

              context 'declares instance predicsates' do
                %i[first second third].each do |meth|
                  it { is_expected.to respond_to("#{meth}?") }
                end
              end

              context 'initial state' do
                it { expect(subject.state).to eq(:first) }
              end
            end
          end
        end
      end

      context 'invalid params' do
        context 'when defined the with same name twice' do
          subject do
            klass.class_eval do
              state_machine do
                state :first
                state :first
              end
            end
          end

          it { expect { subject }.to raise_error(Yasm::StateAlreadyDefined) }
        end
      end
    end

    describe '.event' do
      context 'valid params' do
        context 'single parameter' do
          before do
            klass.class_eval do
              state_machine do
                event :first
              end
            end
          end

          context 'class level behavior' do
            subject { klass.__events__ }

            it { expect(subject.size).to eq(1) }
            it { expect(subject.first).to be_an_instance_of(Yasm::Event) }
          end

          context 'instance level behavior' do
            subject { klass.new }

            it { is_expected.to respond_to(:first) }
            it { is_expected.to respond_to(:first!) }
          end
        end
      end

      context 'invalid params' do
        context 'when defined the with same name twice' do
          subject do
            klass.class_eval do
              state_machine do
                event :first
                event :first
              end
            end
          end

          it { expect { subject }.to raise_error(Yasm::EventAlreadyDefined) }
        end
      end
    end

    describe '.transition' do
      context 'valid params' do
        before do
          klass.class_eval do
            state_machine do
              state :initial, initial: true
              state :final
              event :move do
                transition from: :initial, to: :final
              end
            end
          end
        end

        context 'class level behavior' do
          subject { klass.__transitions__ }

          # it { is_expected.to eq([{event: :move, from: [:initial], to: :final}]) }
        end

        context 'instance level behavior' do
          let(:obj) { klass.new }

          it { expect { obj.move }.to change { obj.state }.from(:initial).to(:final) }
        end
      end

      context 'invalid params' do
        context 'trasition applied to wrong initial state' do
          before do
            klass.class_eval do
              state_machine do
                state :initial, initial: true
                state :middle
                state :final

                event :move do
                  transition from: :middle, to: :final
                end
              end
            end
          end 

          context 'instance level behavior' do
            let(:obj) { klass.new }

            it { expect { obj.move! }.to raise_error(Yasm::TransitionNotPermitted) }
            it { expect { obj.move }.to_not change { obj.state } }
          end
        end

        context 'missing state in `from` parameter' do
          subject do
            klass.class_eval do
              state_machine do
                state :initial, initial: true
                state :middle
                state :final

                event :move do
                  transition from: :missing, to: :final
                end
              end
            end
          end

          it { expect { subject }.to raise_error(Yasm::MissingState) }
        end

        context 'missing state in `to` parameter' do
          subject do
            klass.class_eval do
              state_machine do
                state :initial, initial: true
                state :middle
                state :final

                event :move do
                  transition from: :middle, to: :missing
                end
              end
            end
          end

          it { expect { subject }.to raise_error(Yasm::MissingState) }
        end
      end
    end
  end

  context 'instance methods' do
    it { expect(klass.new).to respond_to(:state) }
  end
end
