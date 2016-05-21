require 'spec_helper'

describe Tutor::Attributes::Blocks::Alias::Writer do
  context "has instance behavior" do
    subject { instance }
    let(:instance) { described_class.new(aliased_name) }
    let(:aliased_name) { :test }

    describe "#aliased_name" do
      subject { super().aliased_name }
      it { is_expected.to eq(aliased_name) }
    end
    describe "#block" do
      subject { super().block }
      it { is_expected.to be_a_kind_of(Proc) }

      context "when invoked with an object" do
        subject { super().call(object, value) }
        let(:object) { double(:object) }
        let(:value) { double(:value) }
        it { expect(object).to receive(:send).with(aliased_name, value); subject }
      end
    end
  end
end