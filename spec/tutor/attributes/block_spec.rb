require 'spec_helper'

describe Tutor::Attributes::Block do
  context "has instance behavior" do
    subject { instance }
    let(:instance) { described_class.new(&block) }
    let(:block) { Proc.new { } }

    describe "#block" do
      subject { super().block }
      it { is_expected.to be_a_kind_of(Proc) }
    end
  end
end
