module I18n
  module Locale
    class Fallbacks < Hash
      def map(*args, &block)
        if args.count == 1 && !block
          mappings = args.first
          mappings.each do |from, to|
            from = from.to_sym
            to = Array(to)
            to.each do |_to| # rubocop:disable Lint/UnderscorePrefixedVariableName
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
