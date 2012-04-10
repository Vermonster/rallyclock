Sequel.migration do
  up do
    create_table(:clients) do
      primary_key :id
      String :name
      String :account
      String :description, :text => true
      TrueClass :active
      foreign_key :group_id, :groups
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:clients)
  end
end


