require 'spec_helper'

describe Tutor::Attributes::Blocks::Alias::Reader do
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
        subject { super().call(object) }
        let(:object) { double(:object) }
        it { expect(object).to receive(:send).with(aliased_name); subject }
      end
    end
  end
end