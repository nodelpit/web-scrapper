class ChangeRoleToBeIntegerInUsers < ActiveRecord::Migration[8.0]
  def up
    # Crée une nouvelle colonne temporaire
    add_column :users, :role_tmp, :integer, default: 0

    # Met à jour directement avec SQL
    execute <<-SQL
      UPDATE users
      SET role_tmp = CASE
        WHEN role = 'admin' THEN 1
        ELSE 0
      END;
    SQL

    # Supprime l'ancienne colonne
    remove_column :users, :role

    # Renomme la nouvelle colonne
    rename_column :users, :role_tmp, :role
  end

  def down
    change_column :users, :role, :string, default: 'user'
  end
end
