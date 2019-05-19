migrate "1-updated_at-trigger" do |db|
  db.execute <<-SQL
  CREATE OR REPLACE FUNCTION update_modified_column()
  RETURNS TRIGGER AS $$
  BEGIN
    NEW."updated_at" = now();
    RETURN NEW;
  END;
  $$ language 'plpgsql';
  SQL
end

add_updated_at_trigger = -> (db, table_name) {
  db.execute <<-SQL
    CREATE TRIGGER update_#{table_name}_updatedAt
    BEFORE UPDATE ON #{table_name}
    FOR EACH ROW
    EXECUTE PROCEDURE update_modified_column();
  SQL
}

migrate "2-users" do |db|
  db.create_table(:users) do
    primary_key :id
    Text :email, null: false, unique: true
    Text :name, null: false
    Text :crypted_password
    Time :created_at, default: Sequel.function(:now)
    Time :updated_at
  end

  add_updated_at_trigger.(db, :users)
end

migrate "3-eaccounting" do |db|
  db.create_table(:eaccounting_integrations) do
    primary_key :id

    Text :name, null: false
    Text :environment, null: false

    Text :access_token
    Text :refresh_token
    Time :token_expires_at

    Time :created_at, default: Sequel.function(:now)
  end
end
