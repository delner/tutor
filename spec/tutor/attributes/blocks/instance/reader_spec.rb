require 'spec_helper'

describe Tutor::Attributes::Blocks::Instance::Reader do
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
        subject { super().call(object) }
        let(:object) { double(:object) }
        it { expect(object).to receive(:instance_variable_get).with("@#{name.to_s}".to_sym); subject }
      end
    end
  end
end