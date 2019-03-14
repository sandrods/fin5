module EnumPlus
  extend ActiveSupport::Concern

  included do
  end

  class_methods do

    def enum_plus(name, values)
      enum name.to_sym => values.keys

      define_method "#{name}_txt" do
        tipo_sym = send(name).to_sym
        values[tipo_sym]
      end

      plural_name = name.to_s.pluralize

      define_singleton_method "#{plural_name}_to_select" do |search: false|
        if search
          values.map { |k, v| [v, send(plural_name)[k]] }
        else
          values.map { |k, v| [v, k] }
        end
      end

      define_singleton_method "#{plural_name}_txt" do |value|

        if values.has_key?(value.to_s.to_sym) # status_txt('aberta') || status_txt(:aberta)
          values[value.to_sym]

        elsif k = send(plural_name).key(Integer(value)) rescue nil # status_txt(0) || status_txt('0')
          values[k.to_sym]

        else
          ''
        end

      end

      values.each do |k, v|
        const_set "#{name}_#{k}".upcase, k.to_s
      end

    end

  end

end
