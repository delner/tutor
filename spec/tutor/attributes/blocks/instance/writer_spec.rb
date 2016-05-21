require 'spec_helper'

describe Tutor::Attributes::Blocks::Instance::Writer do
  context "has instance behavior" do
    subject { instance }
    let(:instance) { described_class.new(name) }
    let(:name) { :test }

    describe "#name" do
      subject { super().name }
      it { is_expected.to eq(name) }
    end
    describe "#block" do
      subject { super().block }
      it { is_expected.to be_a_kind_of(Proc) }

      context "when invoked with an object" do
        subject { super().call(object, value) }
        let(:object) { double(:object) }
        let(:value) { double(:value) }
        it { expect(object).to receive(:instance_variable_set).with("@#{name.to_s}".to_sym, value); subject }
      end
    end
  end
end