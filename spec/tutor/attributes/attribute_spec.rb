require 'spec_helper'

describe Tutor::Attributes::Attribute do
  context "has instance behavior" do
    subject { instance }
    let(:instance) { described_class.new(name, options) }
    let(:name) { :test }
    let(:options) { {} }

    let(:klass) { stub_const "TestClass", Class.new; TestClass }

    describe "#initialize" do
      context "given no options" do
        it { expect(subject.name).to eq(name) }
        it { expect(subject.type).to be nil }
        it { expect(subject.nullable).to be true }
        it { expect(subject.default).to be nil }
        it { expect(subject.override).to be false }
        it { expect(subject.alias).to be nil }
        it { expect(subject.get).to be_a_kind_of(Tutor::Attributes::Blocks::Instance::Reader) }
        it { expect(subject.set).to be_a_kind_of(Tutor::Attributes::Blocks::Instance::Writer) }
      end
      context "given an alias option" do
        let(:aliased_name) { :aliased_method }
        let(:options) { { alias: aliased_name} }
        it { expect(subject.get).to be_a_kind_of(Tutor::Attributes::Blocks::Alias::Reader) }
        it { expect(subject.set).to be_a_kind_of(Tutor::Attributes::Blocks::Alias::Writer) }
      end
      context "given a get option" do
        let(:custom_block) { lambda { } }
        let(:options) { { get: custom_block } }
        it { expect(subject.get).to be_a_kind_of(Tutor::Attributes::Block) }
        it { expect(subject.get.block).to eq(custom_block) }
      end
      context "given a set option" do
        let(:custom_block) { lambda { } }
        let(:options) { { set: custom_block } }
        it { expect(subject.set).to be_a_kind_of(Tutor::Attributes::Block) }
        it { expect(subject.set.block).to eq(custom_block) }
      end
      context "given an override option" do
        let(:value) { double(:override_value) }
        let(:options) { { override: value } }
        it { expect(subject.override).to be value }
      end
      context "given a default option" do
        let(:value) { double(:default_value) }
        let(:options) { { default: value } }
        it { expect(subject.default).to be value }
      end
    end
    
    describe "#add_attribute_methods" do
      subject { super().add_attribute_methods(klass) }
      let(:klass) { stub_const "TestClass", Class.new; TestClass }
      
      it { is_expected.to be_a_kind_of(Array) }
      it { is_expected.to have(2).items }
      it do
        expect(instance).to receive(:add_reader_method).with(klass)
        expect(instance).to receive(:add_writer_method).with(klass)
        subject
      end

      context "when the name conflicts with an existing method" do
        let(:proxy) { double('proxy') }
        let(:existing_method_body) { Proc.new { proxy.invoked } }
        before(:each) { klass.send(:define_method, name, &existing_method_body) }

        it do
          count = 0
          allow_any_instance_of(Tutor::Attributes::Method).to receive(:define_on).with(klass, override: false) { count += 1 }
          subject
          expect(count).to eq(2)
        end
        context "but the override option has been set" do
          let(:options) { { override: true } }
          it do
            count = 0
            allow_any_instance_of(Tutor::Attributes::Method).to receive(:define_on).with(klass, override: true) { count += 1 }
            subject
            expect(count).to eq(2)
          end
        end
      end
    end

    shared_examples_for "a method adder" do |name, custom_attribute|
      it { is_expected.to be_a_kind_of(Tutor::Attributes::Method) }
      it { subject; expect(klass.method_defined?(name)).to be true }
      context "with a custom method" do
        let(:options) { { custom_attribute => custom_block } }
        let(:custom_block) { lambda { } }
        it { expect(subject.body).to be_a_kind_of(Tutor::Attributes::Block) }
        it { expect(subject.body.block).to eq(custom_block) }
        context "with given false" do
          let(:custom_block) { false }
          it { is_expected.to be nil }
        end
        context "with given nil" do
          let(:custom_block) { nil }
          it { is_expected.to be nil }
        end
      end
    end

    describe "#add_reader_method" do
      subject { super().add_reader_method(klass) }
      it { method = subject; expect(instance.reader_method).to eq(method) }
      it_behaves_like "a method adder", :test, :get
    end

    describe "#add_writer_method" do
      subject { super().add_writer_method(klass) }
      it { method = subject; expect(instance.writer_method).to eq(method) }
      it_behaves_like "a method adder",:test=, :set
    end
  end
end