# rubocop:disable all

module I18n
  module Locale
    class Fallbacks < Hash
      def [](locale)
        raise InvalidLocale.new(locale) if locale.nil?
        raise Disabled.new('fallback#[]') if locale == false
        locale = locale.to_sym
        # super || store(locale, compute(locale))
        super || [] # monkey patch: do not add new fallback key on the fly
      end

      def map(*args, &block)
        if args.count == 1 && !block
          mappings = args.first
          mappings.each do |from, to|
            from = from.to_sym
            to = Array(to)
            to.each do |_to|
              @map[from] ||= []
              @map[from] << _to.to_sym
            end
          end
          replace(@map) # monkey patch: https://github.com/ruby-i18n/i18n/issues/645
        else
          @map.map(*args, &block)
        end
      end
    end
  end
end
