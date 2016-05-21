require 'spec_helper'

describe Tutor::Attributes::Method do
  context "has instance behavior" do
    subject { instance }
    let(:instance) { described_class.new(name, options, &body) }
    let(:name) { :test }
    let(:options) { {} }
    let(:body) { Proc.new { } }

    describe "#define_on" do
      subject { super().define_on(klass) }

      context "when invoked with a class" do
        let(:klass) { stub_const "TestClass", Class.new; TestClass }
        it { subject; expect(klass.new).to respond_to(name) }
        context "that already has a method with the same name" do
          before(:each) { klass.send(:define_method, name, &body) }
          it { expect { subject }.to raise_error(NameError) }
          context "but the override option is true" do
            subject { instance.define_on(klass, override: true) }
            it { subject; expect(klass.new).to respond_to(name) }
          end
        end
      end
    end
    describe "#method_block" do
      subject { super().method_block }
      it { is_expected.to be_a_kind_of(Proc) }

      context "given the instance has a body" do
        let(:caller_class) { stub_const "TestClass", Class.new; TestClass }
        let(:caller) { caller_class.new }
        let(:arg) { double('arg') }
        let(:proxy) { double('proxy') }
        let(:body) { Proc.new { |o, arg| proxy.body(o, arg) } }

        before(:each) do
          block = subject
          caller_class.send(:define_method, name, block)
        end

        it do
          expect(proxy).to receive(:body).with(caller, arg)
          caller.send(name, arg)
        end

        context "and a pre_execute block" do
          let(:pre_execute) { Proc.new { |o, arg| proxy.pre_execute(o, arg) } }
          let(:options) { { pre_execute: pre_execute } }
          it do
            expect(proxy).to receive(:pre_execute).with(caller, arg).ordered
            expect(proxy).to receive(:body).with(caller, arg).ordered
            caller.send(name, arg)
          end
        end
        context "and a post_execute block" do
          let(:post_execute) { Proc.new { |o, arg| proxy.post_execute(o, arg) } }
          let(:options) { { post_execute: post_execute } }
          it do
            expect(proxy).to receive(:body).with(caller, arg).ordered
            expect(proxy).to receive(:post_execute).with(caller, arg).ordered
            caller.send(name, arg)
          end
        end
      end
    end
  end
end