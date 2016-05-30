module Tutor::Attributes
  module Type
    attr_accessor \
      :type,
      :nullable

    def valid_value_type?(value)
      self.type.nil? || (self.nullable && value.nil?) || !(value.class <= self.type).nil?
    end

    def check_value_type!(value, name: nil)
      unless self.valid_value_type?(value)
        raise ArgumentError.new("Invalid value type '#{value.class.name}' assigned to attribute#{" '#{name}'" if name}!")
      end
      true
    end
  end
end