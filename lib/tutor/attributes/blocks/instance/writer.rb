module Tutor::Attributes::Blocks::Instance
  class Writer < Tutor::Attributes::Block
    attr_reader :name, :block

    def initialize(name)
      self.tap do |block|
        @name = name
        super() do |object, value|
          object.instance_variable_set("@#{block.name.to_s}".to_sym, value)
        end
      end
    end
  end
end