require 'spec_helper'

describe Tutor::Attributes::Default do
  context "when included into a class" do
    let(:test_class) do
      stub_const "TestClass", Class.new
      TestClass.send(:include, described_class)
      TestClass
    end
    subject { test_class }

    context "adds instance behavior" do
      let(:instance) { test_class.new }
      subject { instance }

      describe "#default_value_for" do
        subject { super().default_value_for(object) }
        let(:object) { double("object") }

        context "given the instance has" do
          context "no default value" do
            it { is_expected.to be_nil }
          end
          context "a default value" do
            before(:each) { instance.default = default }
            let(:default_value) { double('default value') }
            context "that is a static value" do
              let(:default) { default_value }
              it { is_expected.to eq(default_value) }
            end
            context "that is a block" do
              let(:default) { Proc.new { default_value } }
              it { is_expected.to eq(default_value) }
              context "that accepts an argument" do
                let(:default) { Proc.new { |o| default_value.arg(o) } }
                before(:each) { expect(default_value).to receive(:arg).with(object).and_return(default_value) }
                it { is_expected.to eq(default_value) }
              end
            end
            context "that is a lambda" do
              let(:default) { -> { default_value } }
              it { is_expected.to eq(default_value) }
              context "that accepts an argument" do
                let(:default) { lambda { |o| default_value.arg(o) } }
                before(:each) { expect(default_value).to receive(:arg).with(object).and_return(default_value) }
                it { is_expected.to eq(default_value) }
              end
            end
          end
        end
      end
    end
  end
end