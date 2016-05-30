module Tutor::Attributes
  class Attribute
    include Tutor::Attributes::Default
    include Tutor::Attributes::Type

    attr_accessor \
      :name,
      :get,
      :set,
      :alias,
      :reader_method,
      :writer_method,
      :override

    def initialize(name, options = {})
      self.name = name.to_sym
      self.type = options[:type]
      self.nullable = options.has_key?(:nullable) ? options[:nullable] : true
      self.default = options[:default]
      self.override = options.has_key?(:override) ? options[:override] : false
      self.alias = options[:alias]
      self.get = options.has_key?(:get) ? options[:get] && Tutor::Attributes::Block.new(&options[:get]) : get_default
      self.set = options.has_key?(:set) ? options[:set] && Tutor::Attributes::Block.new(&options[:set]) : set_default
    end

    def add_attribute_methods(klass)
      [
        add_reader_method(klass),
        add_writer_method(klass)
      ].compact
    end

    def add_reader_method(klass)
      return if !self.get
      self.reader_method = add_method(
        klass,
        self.name,
        body: self.get
      )
    end

    def add_writer_method(klass)
      return if !self.set
      self.writer_method = add_method(
        klass,
        "#{self.name}=".to_sym,
        pre_execute: lambda { |object, value| self.check_value_type!(value, name: self.name) },
        body: self.set
      )
    end

    private

    def add_method(klass, name, options = {}, &block)
      Tutor::Attributes::Method.new(name, options, &block).tap { |m| m.define_on(klass, override: self.override) }
    end

    def get_default
      if self.alias
        Tutor::Attributes::Blocks::Alias::Reader.new(self.alias)
      else
        Tutor::Attributes::Blocks::Instance::Reader.new(self.name)
      end
    end

    def set_default
      if self.alias
        Tutor::Attributes::Blocks::Alias::Writer.new(self.alias)
      else
        Tutor::Attributes::Blocks::Instance::Writer.new(self.name)
      end
    end
  end
end