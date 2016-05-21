module Tutor::Attributes
  class Block
    attr_reader :block

    def initialize(&block)
      self.tap { |b| @block = block }
    end
  end
end