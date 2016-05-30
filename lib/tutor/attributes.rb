module Tutor::Attributes
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
  end
 
  module ClassMethods
    def attributes
      base_attributes = self.superclass.respond_to?(:attributes) ? self.superclass.attributes : []
      (__attributes + base_attributes).uniq(&:name)
    end

    def has_attribute?(name)
      attributes.any? { |attribute| attribute.name == name }
    end

    protected

    def attribute(name, options = {})
      attribute = Tutor::Attributes::Attribute.new(name, options)
      attribute.tap do |a|
        __attributes << a
        a.add_attribute_methods(self)
      end
    end

    private

    def __attributes
      @attributes ||= []
    end
  end

  module InstanceMethods
    def initialize_attributes(attributes = {})
      self.tap do |object|
        # Set any explicitly passed attribute values first
        set_attributes(attributes)
        # Then defaults last, so they can use any explicitly provided values
        default_attributes = object.class.attributes.select { |attribute| !attributes.has_key?(attribute.name) }
        default_attributes.each do |attribute|
          # Do them individually so one default can use another
          set_attribute(attribute.name, attribute.default_value_for(object)) if !attribute.default.nil?
        end
      end
    end

    def set_attributes(attributes = {})
      self.tap do |object|
        attributes.each do |name, value|
          set_attribute(name, value)
        end
      end
    end

    def set_attribute(name, value)
      raise NameError.new("Unknown attribute!", name) unless self.class.has_attribute?(name)
      self.send("#{name.to_s}=".to_sym, value)
    end
  end
end

require 'tutor/attributes/block'
require 'tutor/attributes/blocks'
require 'tutor/attributes/method'
require 'tutor/attributes/default'
require 'tutor/attributes/type'
require 'tutor/attributes/attribute'