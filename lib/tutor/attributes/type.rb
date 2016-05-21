module Tutor::Attributes
  module Type
    attr_accessor \
      :type,
      :nullable

    def valid_value_type?(value)
      self.type.nil? || (self.nullable && value.nil?) || !(value.class <= self.type).nil?
    end

    def check_value_type!(value)
      raise ArgumentError.new("Invalid value type assigned to attribute!") unless self.valid_value_type?(value)
      true
    end
  end
end