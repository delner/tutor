require 'spec_helper'

describe Tutor::Attributes::Type do
  context "when included into a class" do
    let(:test_class) do
      stub_const "TestClass", Class.new
      TestClass.send(:include, described_class)
      TestClass
    end
    subject { test_class }

    context "adds instance behavior" do
      let(:instance) { test_class.new }
      let(:type) { stub_const "TypeClass", Class.new; TypeClass }
      let(:value) { double('value') }
      subject { instance }

      describe "#valid_value_type?" do
        subject { super().valid_value_type?(value) }
        context "when the instance has" do
          context "no type" do
            it { is_expected.to be true }
          end
          context "a type" do
            before(:each) { instance.type = type }
            
            context "and is invoked with a value of" do
              let(:value) { value_type.new }
              context "nil" do
                let(:value) { nil }
                it { is_expected.to be false }
                context "but nullable is set" do
                  before(:each) { instance.nullable = true }
                  it { is_expected.to be true }
                end
              end
              context "the same type" do
                let(:value_type) { type }
                it { is_expected.to be true }
              end
              context "an inherited type" do
                let(:value_type) { stub_const "InheritedTypeClass", Class.new(type); InheritedTypeClass }
                it { is_expected.to be true }
              end
              context "of a different type" do
                let(:value_type) { stub_const "BadTypeClass", Class.new; BadTypeClass }
                it { is_expected.to be false }
              end
            end
          end
        end
      end
      describe "#check_value_type!" do
        subject { super().check_value_type!(value) }

        context "when the value is valid" do
          before(:each) { expect(instance).to receive(:valid_value_type?).with(value).and_return(true) }
          it { is_expected.to be true }
        end

        context "when the value is invalid" do
          before(:each) { expect(instance).to receive(:valid_value_type?).with(value).and_return(false) }
          it { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end
  end
end