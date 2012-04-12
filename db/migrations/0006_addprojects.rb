Sequel.migration do
  up do
    create_table(:projects) do
      primary_key :id
      String :name
      String :description, :text => true
      String :code
      TrueClass :active, :default => true
      TrueClass :billable, :default => true
      foreign_key :client_id, :clients
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:projects)
  end
end

