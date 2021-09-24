# rubocop:disable all
module I18n::Tasks
  module Data
    class FileSystemBase
      protected

      def read_locale(locale, paths: config[:read])
        Array(paths).flat_map do |path|
          Dir.glob format(path, locale: locale)
        end.map do |path|
          [path.freeze, load_file(path) || {}]
        end.map do |path, data|
          filter_nil_keys! path, data
          # add patch to merge R18n locale-less format
          data = {locale => data} if data && !(data.size == 1 && data.keys.first == locale)
          Data::Tree::Siblings.from_nested_hash(data).tap do |s|
            s.leaves { |x| x.data.update(path: path, locale: locale) }
          end
        end.reduce(Tree::Siblings[locale => {}], :merge!)
      end
    end
  end
end

module I18n::Tasks
  module MissingKeys
    def missing_plural_forest(locales, _base = base_locale)
      locales.each_with_object(empty_forest) do |locale, forest|
        required_keys = required_plural_keys_for_locale(locale)
        next if required_keys.empty?

        tree = empty_forest
        plural_nodes data[locale] do |node|
          children = node.children
          present_keys = Set.new(children.map { |c| c.key.to_sym })
          next if present_keys.include?(:n) # skip entire missing keys check if contains R18n "n"
          next if ignore_key?(node.full_key(root: false), :missing)
          next if present_keys.superset?(required_keys)

          tree[node.full_key] = node.derive(
            value: children.to_hash,
            children: nil,
            data: node.data.merge(missing_keys: (required_keys - present_keys).to_a)
          )
        end
        tree.set_root_key!(locale, type: :missing_plural)
        forest.merge!(tree)
      end
    end
  end
end

module I18n::Tasks::PluralKeys
  # redefine constants for R18n style plurals
  CLDR_CATEGORY_KEYS = %w[zero one two few many other 0 1 2 3 4 5 6 7 8 9 n].freeze
  PLURAL_KEY_SUFFIXES = Set.new CLDR_CATEGORY_KEYS
  PLURAL_KEY_RE = /\.(?:#{CLDR_CATEGORY_KEYS * '|'})$/
end
# rubocop:enable all