class AddUserToTags < ActiveRecord::Migration[8.1]
  def change
    add_reference :tags, :user, null: true, foreign_key: true

    remove_index :tags, :name
    # PostgreSQLのデフォルトではNULLは互いに異なる値として扱われるため、
    # nulls_not_distinct: true を指定して共有タグ（user_id: nil）同士の重複も防ぐ
    add_index :tags, [ :user_id, :name ], unique: true, nulls_not_distinct: true
  end
end
