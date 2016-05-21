module Tutor::Attributes
  module Default
    attr_accessor :default

    def default_value_for(object)
      if self.default.class <= Proc
        if self.default.lambda? && self.default.parameters.empty?
          self.default.call
        else
          self.default.call(object)
        end
      else
        self.default
      end
    end
  end
end