module ActsAsTaggableOn
  class TagParser < GenericParser
    def parse
      ActsAsTaggableOn::TagList.new.tap do |tag_list|
        tag_list.add replace_with_tag_alias(clean(@tag_list))
      end
    end

    private

    def clean(string)
      string = string.to_s
      return [] if string.blank?

      string.normalize.tr("'", ?\u02BC).downcase.split(",").map do |t| # not sure if it is called on save
        t.strip.delete(" ").gsub(/[\p{XIDC}\p{No}\u00B7\u05F3\u05F4\u0F0B\u200C\u200D]/u, "")
      end
    end

    def replace_with_tag_alias(tags)
      tags.map do |tag|
        possible_alias = tag
        found_alias = tag
        until possible_alias.nil?
          possible_alias = find_tag_alias(possible_alias)
          found_alias = possible_alias if possible_alias
        end
        found_alias
      end
    end

    def find_tag_alias(tag)
      # "&." is "Safe Navigation"; ensure not called on nil
      alias_for = Tag.find_by(name: tag)&.alias_for
      alias_for.presence
    end
  end
end
