Sequel.migration do
  up do
    create_table(:memberships) do
      primary_key :id
      TrueClass :client
      TrueClass :admin
      TrueClass :owner
      foreign_key :user_id, :users
      foreign_key :group_id, :groups
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:memberships)
  end
end

