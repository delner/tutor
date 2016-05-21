module Tutor::Attributes
  class Method
    attr_accessor \
      :name,
      :body,
      :pre_execute,
      :post_execute

    def initialize(name, options = {}, &block)
      self.name = name.to_sym
      self.body = block ? Tutor::Attributes::Block.new(&block) : options[:body]
      self.pre_execute = options[:pre_execute]
      self.post_execute = options[:post_execute]
    end

    def define_on(klass, override: false)
      if !override && klass.method_defined?(self.name)
        raise NameError.new("Attribute name conflicts with existing method!", self.name) 
      else
        klass.send(:define_method, self.name, &method_block)
      end
    end

    def method_block
      method = self
      Proc.new do |*args|
        return_value = nil
        method.pre_execute.call(self, *args) unless method.pre_execute.nil?
        return_value = method.body.block.call(self, *args) unless method.body.nil?
        method.post_execute.call(self, *args) unless method.post_execute.nil?
        return_value
      end
    end
  end
end