Sequel.migration do
  up do
    create_table(:entries) do
      primary_key :id
      String :note
      Integer :time
      foreign_key :user_id, :users
      DateTime :created_at
      DateTIme :updated_at
    end
  end

  down do
    drop_table(:entries)
  end
end

