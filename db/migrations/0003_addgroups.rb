Sequel.migration do
  up do
    create_table(:groups) do
      primary_key :id
      String :name
      String :handle
      foreign_key :owner_id, :users
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:groups)
  end
end
