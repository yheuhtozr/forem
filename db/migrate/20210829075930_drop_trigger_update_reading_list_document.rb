class DropTriggerUpdateReadingListDocument < ActiveRecord::Migration[6.1]
  def up
    drop_trigger("update_reading_list_document", "articles", :generated => true)
  end

  def down
    create_trigger("update_reading_list_document", :generated => true, :compatibility => 1).
        on("articles").
        name("update_reading_list_document").
        before(:insert, :update).
        for_each(:row).
        declare("l_org_vector tsvector; l_user_vector tsvector") do
      <<-SQL_ACTIONS
NEW.reading_list_document :=
  setweight(to_tsvector('simple'::regconfig, unaccent(coalesce(NEW.title, ''))), 'A') ||
  setweight(to_tsvector('simple'::regconfig, unaccent(coalesce(NEW.cached_tag_list, ''))), 'B') ||
  setweight(to_tsvector('simple'::regconfig, unaccent(coalesce(NEW.body_markdown, ''))), 'C') ||
  setweight(to_tsvector('simple'::regconfig, unaccent(coalesce(NEW.cached_user_name, ''))), 'D') ||
  setweight(to_tsvector('simple'::regconfig, unaccent(coalesce(NEW.cached_user_username, ''))), 'D') ||
  setweight(to_tsvector('simple'::regconfig,
    unaccent(
      coalesce(
        array_to_string(
          -- cached_organization is serialized to the DB as a YAML string, we extract only the name attribute
          regexp_match(NEW.cached_organization, 'name: (.*)$', 'n'),
          ' '
        ),
        ''
      )
    )
  ), 'D');
      SQL_ACTIONS
    end
  end
end
