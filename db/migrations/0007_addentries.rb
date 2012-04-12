Sequel.migration do
  up do
    create_table(:entries) do
      primary_key :id
      String :note, :text => true
      Integer :time
      TrueClass :billable, :default => true
      foreign_key :user_id, :users
      Date :date
      DateTime :created_at
      DateTime :updated_at
      foreign_key :project_id, :projects
    end
  end

  down do
    drop_table(:entries)
  end
end

