class AddFullTextSearchIndexToDocuments < ActiveRecord::Migration[6.1]
  # https://www.clear-code.com/blog/2015/11/9.html
  # https://github.com/ankane/strong_migrations#adding-an-index-non-concurrently
  disable_ddl_transaction!

  def up
    safety_assured {
      # Perfection is immutable. But for things imperfect, change is the way to perfect them.
      # -- Owen Feltham

      # http://fromto.cc/hosokawa/diary/2011/20110214-mita/
      execute <<~FUNC
      CREATE OR REPLACE FUNCTION array_to_string2(text[]) RETURNS text
        LANGUAGE sql 
        IMMUTABLE STRICT 
        AS $$
            SELECT array_to_string($1, ' ') 
        $$;
      FUNC
    }

    remove_index :articles, column: :reading_list_document, algorithm: :concurrently
    remove_index :audit_logs, column: :data, algorithm: :concurrently
    remove_index :classified_listings, name: :index_classified_listings_on_search_fields_as_tsvector, algorithm: :concurrently
    remove_index :comments, name: :index_comments_on_body_markdown_as_tsvector, algorithm: :concurrently
    remove_index :podcast_episodes, name: :index_podcast_episodes_on_search_fields_as_tsvector, algorithm: :concurrently

    safety_assured { remove_column :articles, :reading_list_document, :tsvector }

    add_index :articles, "title pgroonga_varchar_full_text_search_ops_v2, cached_tag_list pgroonga_varchar_full_text_search_ops_v2, body_markdown, cached_user_name pgroonga_varchar_full_text_search_ops_v2, cached_user_username pgroonga_varchar_full_text_search_ops_v2, array_to_string2(regexp_match(cached_organization, 'name: (.*)$', 'n'))", using: "pgroonga", name: :index_articles_full_text, algorithm: :concurrently
    add_index :audit_logs, :data, using: "pgroonga", algorithm: :concurrently
    add_index :classified_listings, "body_markdown, cached_tag_list pgroonga_varchar_full_text_search_ops_v2, location pgroonga_varchar_full_text_search_ops_v2, slug pgroonga_varchar_full_text_search_ops_v2, title pgroonga_varchar_full_text_search_ops_v2", using: "pgroonga", name: :index_classified_listings_full_text, algorithm: :concurrently
    add_index :comments, :body_markdown, using: "pgroonga", algorithm: :concurrently
    add_index :podcast_episodes, "body, subtitle pgroonga_varchar_full_text_search_ops_v2, title pgroonga_varchar_full_text_search_ops_v2", using: "pgroonga", name: :index_podcast_episodes_full_text, algorithm: :concurrently
  end

  def down
    safety_assured { execute "DROP FUNCTION array_to_string2(text) cascade;" }

    remove_index :articles, name: :index_articles_full_text, algorithm: :concurrently
    remove_index :audit_logs, column: :data, algorithm: :concurrently
    remove_index :classified_listings, name: :index_classified_listings_full_text, algorithm: :concurrently
    remove_index :comments, column: :body_markdown, algorithm: :concurrently
    remove_index :podcast_episodes, name: :index_podcast_episodes_full_text, algorithm: :concurrently

    add_column :articles, :reading_list_document, :tsvector

    add_index :articles, :reading_list_document, using: :gin, algorithm: :concurrently
    add_index :audit_logs, :data, using: :gin, algorithm: :concurrently

    classified_listings_query = <<-SQL
    (
      to_tsvector('simple'::regconfig, COALESCE((body_markdown)::text, ''::text)) ||
      to_tsvector('simple'::regconfig, COALESCE((cached_tag_list)::text, ''::text)) ||
      to_tsvector('simple'::regconfig, COALESCE((location)::text, ''::text)) ||
      to_tsvector('simple'::regconfig, COALESCE((slug)::text, ''::text)) ||
      to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text))
    )
    SQL

    unless index_name_exists?(:classified_listings, :index_classified_listings_on_search_fields_as_tsvector)
      add_index(
        :classified_listings,
        classified_listings_query,
        using: :gin,
        name: :index_classified_listings_on_search_fields_as_tsvector,
        algorithm: :concurrently
      )
    end

    unless index_name_exists?(:comments, :index_comments_on_body_markdown_as_tsvector)
      add_index :comments, "to_tsvector('simple'::regconfig, COALESCE((body_markdown)::text, ''::text))", using: :gin, name: :index_comments_on_body_markdown_as_tsvector, algorithm: :concurrently
    end

    podcast_episodes_query = <<-SQL
      ((((
        to_tsvector('simple'::regconfig, COALESCE(body, ''::text)) ||
        to_tsvector('simple'::regconfig, COALESCE((subtitle)::text, ''::text))) ||
        to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text
      )))))
    SQL

    unless index_name_exists?(:podcast_episodes, :index_podcast_episodes_on_search_fields_as_tsvector)
      add_index :podcast_episodes,
                podcast_episodes_query,
                using: :gin,
                name: :index_podcast_episodes_on_search_fields_as_tsvector,
                algorithm: :concurrently
    end
  end
end
