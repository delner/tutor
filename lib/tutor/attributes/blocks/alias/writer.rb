module Tutor::Attributes::Blocks::Alias
  class Writer < Tutor::Attributes::Block
    attr_reader :aliased_name, :block

    def initialize(aliased_name)
      self.tap do |block|
        @aliased_name = aliased_name
        super() { |object, value| object.send(block.aliased_name, value) }
      end
    end
  end
end