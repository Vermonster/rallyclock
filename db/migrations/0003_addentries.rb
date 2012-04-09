Sequel.migration do
  up do
    create_table(:entries) do
      primary_key :id
      String :note, :text => true
      Integer :time
      TrueClass :billable
      foreign_key :user_id, :users
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:entries)
  end
end
