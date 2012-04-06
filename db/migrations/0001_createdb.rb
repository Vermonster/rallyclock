Sequel.migration do
  up do
    `createdb rallyclock_development`
    `createdb rallyclock_test`
  end
  down do
    run (<<-SQL)
      DROP DATABASE rallyclock_development;
      DROP DATABASE rallyclock_test;
    SQL
  end
end

