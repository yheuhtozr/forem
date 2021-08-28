class EnablePGroonga < ActiveRecord::Migration[6.1]
  # https://www.clear-code.com/blog/2015/11/9.html
  # https://github.com/ankane/strong_migrations#executing-SQL-directly
  def change
    reversible do |r|
      current_database = select_value("SELECT current_database()")

      r.up do
        safety_assured do
          enable_extension("pgroonga")
          execute("ALTER DATABASE \"#{current_database}\" SET search_path = '$user',public,pgroonga,pg_catalog;")
        end
      end

      r.down do
        safety_assured do
          execute("ALTER DATABASE \"#{current_database}\" RESET search_path;")
          disable_extension("pgroonga")
        end
      end
    end
  end
end
