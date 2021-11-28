class ApplicationDecorator
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  delegate_missing_to :@object

  # ActiveModel compatibility
  delegate :to_param, :to_partial_path, :current_page, :total_pages,
           :limit_value, :total_count, :entry_name, :offset_value,
           :last_page?, to: :@object

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def decorated?
    true
  end

  def self.decorate_collection(objects)
    objects.map(&:decorate)
  end
end
