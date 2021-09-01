# rubocop:disable all
module R18n
  class Backend
    def translate(locale, key, options = {})
      return key.map { |k| translate(locale, k, options) } if key.is_a?(Array)

      scope, default, separator = options.values_at(*RESERVED_KEYS)
      params = options.reject { |name, _value| RESERVED_KEYS.include?(name) }

      result = lookup(locale, scope, key, separator, params)

      if result.is_a? Untranslated
        options = options.reject { |opts_key, _value| opts_key == :default }

        default = []        if default.nil?
        default = [default] unless default.is_a? Array

        default.each do |entry|
          case entry
          when Symbol
            value = lookup(locale, scope, entry, separator, params)
            return value unless value.is_a? Untranslated
          when Proc
            proc_key = options.delete(:object) || key
            return entry.call(proc_key, options)
          else
            return entry
          end
        end

        # this line is monkey patched to enable error message passthrough
        throw :exception, ::I18n::MissingTranslation.new(locale, key, options)
      else
        result
      end
    end
  end
end
# rubocop:enable all