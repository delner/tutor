module Tutor::Attributes::Blocks::Alias
  class Reader < Tutor::Attributes::Block
    attr_reader :aliased_name, :block

    def initialize(aliased_name)
      self.tap do |block|
        @aliased_name = aliased_name
        super() { |object| object.send(block.aliased_name) }
      end
    end
  end
end