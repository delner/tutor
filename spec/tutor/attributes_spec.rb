require 'spec_helper'

describe Tutor::Attributes do
  context "when included into a class" do
    let(:test_class) do
      stub_const "TestClass", Class.new
      TestClass.send(:include, described_class)
      TestClass
    end
    subject { test_class }

    context "adds class behavior" do
      describe "#attribute" do
        subject { test_class.send(:attribute, name, options) }
        let(:name) { :test }
        let(:options) { {} }

        context "when invoked with an attribute name" do
          let(:instance) { test_class.new }
          it { subject; expect(instance).to respond_to(name) }
          it { subject; expect(instance).to respond_to("#{name}=") }
        end
      end
      describe "#has_attribute?" do
        subject { super().has_attribute?(name) }
        let(:name) { :test }
        it { is_expected.to be false }
        context "for an attribute that has been defined" do
          before(:each) { test_class.send(:attribute, name) }
          context "on the class" do
            it { is_expected.to be true }
          end
          context "on its superclass" do
            subject { test_subclass.has_attribute?(name) }
            let(:test_subclass) do
              stub_const "TestSubclass", Class.new(test_class)
              TestSubclass.send(:include, described_class)
              TestSubclass
            end
            it { is_expected.to be true }
          end
        end
      end
      describe "#attributes" do
        subject { super().attributes }
        it { is_expected.to be_a_kind_of(Array) }
        it { is_expected.to be_empty }

        context "that when an attribute is defined" do
          before(:each) { test_class.send(:attribute, :test) }
          it { is_expected.to have(1).items }
        end
      end
    end

    context "adds instance behavior" do
      let(:instance) { test_class.new }
      subject { instance }

      shared_examples_for "an attribute collection setter" do
        subject { instance.send(setter_name, *args) }
        context "with a hash of attribute names and values" do
          let(:args) { [attributes] }
          context "that contains" do
            context "an attribute that isn't defined" do
              let(:name) { :test }
              let(:attribute_value) { double('attribute value') }
              let(:attributes) { { name => attribute_value } }
              it { expect { subject }.to raise_error(NameError) }
            end
            context "a valid pair" do
              subject { super(); instance.send(name) }
              let(:name) { :test }
              let(:attribute_value) { double('attribute value') }
              let(:attributes) { { name => attribute_value } }
              before(:each) { test_class.send(:attribute, name) }
              it { is_expected.to eq(attribute_value) }
            end
            context "an attribute that has a bad value" do
              let(:name) { :test }
              let(:attribute_value) { double('attribute value') }
              let(:attributes) { { name => bad_type.new } }
              let(:type) { stub_const "TypeClass", Class.new; TypeClass }
              let(:bad_type) { stub_const "BadTypeClass", Class.new; BadTypeClass }
              before(:each) { test_class.send(:attribute, name, type: type) }
              it { expect { subject }.to raise_error(ArgumentError) }
            end
          end
        end
      end

      describe "#initialize_attributes" do
        let(:setter_name) { :initialize_attributes }
        it_behaves_like "an attribute collection setter"
        context "when invoked with no args" do
          subject { super().initialize_attributes }
          it { is_expected.to eq(instance) }

          context "then any attribute that has a default" do
            subject { super(); instance.send(name) }
            let(:name) { :test }
            let(:default_value) { double('default value') }
            before(:each) { test_class.send(:attribute, name, default: default_value) }
            it { is_expected.to eq(default_value) }
          end
        end
        # This is a bit of an integration test, but it's an interesting case.
        context "when invoked when one attribute default is" do
          subject { super().initialize_attributes }
          let(:name) { :test }
          let(:attributes) { [] }
          before(:each) { attributes.each { |a| test_class.send(:attribute, *a) } }

          context "defined by another" do
            let(:proxy) { double('proxy') }

            let(:attribute_default) { double('attribute default value') }
            let(:attribute_name) { :parent }
            let(:attribute) { [attribute_name, default: attribute_default] }

            let(:dependent_attribute_default) { lambda { |a| proxy.parent(a.send(attribute_name)) } }
            let(:dependent_attribute_name) { :child }
            let(:dependent_attribute) { [dependent_attribute_name, default: dependent_attribute_default] }

            let(:attributes) { [attribute, dependent_attribute] }

            it { expect(proxy).to receive(:parent).with(attribute_default); subject }

            context "but it's defined in the wrong order" do
              let(:attributes) { [dependent_attribute, attribute] }
              it { expect(proxy).to receive(:parent).with(nil); subject }
              context "but the parent attribute was explicitly given a value" do
                subject { instance.initialize_attributes({ attribute_name => explicit_value }) }
                let(:explicit_value) { double('explicit value') }
                it { expect(proxy).to receive(:parent).with(explicit_value); subject }
              end
            end
          end
        end
      end
      describe "#set_attributes" do
        let(:setter_name) { :set_attributes }
        it_behaves_like "an attribute collection setter"
      end
      describe "#set_attribute" do
        subject { super().set_attribute(name, value) }
        let(:name) { :test }
        let(:type) { stub_const "TypeClass", Class.new; TypeClass }
        let(:value) { type.new }

        context "for an attribute that doesn't exist" do
          it { expect { subject }.to raise_error(NameError) }
        end
        context "for an attribute that exists" do
          before(:each) { test_class.send(:attribute, name, type: type) }
          context "and a value of invalid type" do
            let(:bad_type) { stub_const "BadTypeClass", Class.new; BadTypeClass }
            let(:value) { bad_type.new }
            it { expect { subject }.to raise_error(ArgumentError) }
          end
          context "and a value of valid type" do
            it { is_expected.to eq(value) }
          end
          context "in a superclass" do
            subject { subclass_instance.set_attribute(name, value) }
            let(:test_subclass) do
              stub_const "TestSubclass", Class.new(test_class)
              TestSubclass.send(:include, described_class)
              TestSubclass
            end
            let(:subclass_instance) { test_subclass.new }
            it { is_expected.to eq(value) }
          end
        end
      end
    end
  end
end