Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :username
      String :email, :null=>false
      String :password_salt
      String :password_hash
      String :api_key
      DateTime :created_at
      DateTIme :updated_at
    end
  end

  down do
    drop_table(:users)
  end
end
