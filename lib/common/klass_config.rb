# frozen_string_literal: true
module KlassConfig
  def attr_config(attribute, default_value: nil, prefix: nil)
    define_singleton_method(attribute) do |*args|
      method_name = attribute
      method_name.prepend "#{prefix}_" if prefix
      define_singleton_method method_name do
        args.first
      end
      define_method method_name do
        args.first
      end
    end
    define_singleton_method "config_#{attribute}" do
      default_value
    end
    define_method "config_#{attribute}" do
      default_value
    end
  end
end
