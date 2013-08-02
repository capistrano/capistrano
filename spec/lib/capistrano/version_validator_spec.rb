require 'spec_helper'

module Capistrano

  describe VersionValidator do
    let(:validator) { VersionValidator.new(version) }
    let(:version) { stub }

    describe '#new' do
      it 'takes a version' do
        expect(validator)
      end
    end

    describe '#verify' do
      let(:current_version) { '3.0.1' }

      subject { validator.verify }

      before do
        validator.stubs(:current_version).returns(current_version)
      end

      context 'with exact version' do
        context 'valid' do
          let(:version) { '3.0.1' }
          it { should be_true }
        end

        context 'invalid - lower' do
          let(:version) { '3.0.0' }

          it 'fails' do
            expect { subject }.to raise_error
          end
        end

        context 'invalid - higher' do
          let(:version) { '3.0.2' }

          it 'fails' do
            expect { subject }.to raise_error
          end
        end

      end

      context 'with optimistic versioning' do
        context 'valid' do
          let(:version) { '>= 3.0.0' }
          it { should be_true }
        end

        context 'invalid - lower' do
          let(:version) { '<= 2.0.0' }

          it 'fails' do
            expect { subject }.to raise_error
          end
        end
      end



      context 'with pessimistic versioning' do
        context '2 decimal places' do
          context 'valid' do
            let(:version) { '~> 3.0.0' }
            it { should be_true }
          end

          context 'invalid' do
            let(:version) { '~> 3.1.0' }

            it 'fails' do
              expect { subject }.to raise_error
            end
          end
        end

        context '1 decimal place' do
          let(:current_version) { '3.5.0' }

          context 'valid' do
            let(:version) { '~> 3.1' }
            it { should be_true }
          end

          context 'invalid' do
            let(:version) { '~> 3.6' }
            it 'fails' do
              expect { subject }.to raise_error
            end
          end
        end

      end

    end

  end

end
