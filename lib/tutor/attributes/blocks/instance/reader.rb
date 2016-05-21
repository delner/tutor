module Tutor::Attributes::Blocks::Instance
  class Reader < Tutor::Attributes::Block
    attr_reader :name, :block

    def initialize(name, &block)
      self.tap do |block|
        @name = name
        super() do |object|
          object.instance_variable_get("@#{block.name.to_s}".to_sym)
        end
      end
    end
  end
end