class AddTranslationGroupToArticles < ActiveRecord::Migration[6.1]
  def up
    add_column :articles, :translation_group, :bigint
  end

  def down
    safety_assured { remove_column :articles, :translation_group }
  end
end
