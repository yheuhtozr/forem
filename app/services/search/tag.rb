module Search
  class Tag
    ATTRIBUTES = %i[id name hotness_score rules_html supported short_summary bg_color_hex badge_id].freeze

    def self.search_documents(term)
      results = ::Tag.search_by_name(term).supported.includes(:badge).reorder(hotness_score: :desc).select(*ATTRIBUTES)
      serialize(results)
    end

    def self.serialize(results)
      Search::TagSerializer.new(results, is_collection: true).serializable_hash[:data].pluck(:attributes)
    end
    private_class_method :serialize
  end
end
