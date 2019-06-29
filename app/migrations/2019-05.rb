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

migrate "4-journal" do |db|
  db.create_table(:vouchers) do
    Text :id, null: false, primary_key: true

    Integer :year, null: false
    foreign_key :eaccounting_integration_id, :eaccounting_integrations, null: false

    Text :number, null: false
    Date :date, null: false
    Text :comment

    unique [:eaccounting_integration_id, :year, :number]
  end

  db.create_table(:transactions) do
    Text :id, null: false, primary_key: true
    foreign_key :voucher_id, :vouchers, type: :text, null: false, on_delete: :cascade
    Integer :position, null: false

    Integer :account, null: false
    Integer :amount, null: false
    Text :comment

    unique [:voucher_id, :position]
  end
end

migrate "5-queue-system" do |db|
  require 'que'
  Que.connection = db
  Que.migrate!(version: 4)
end

migrate "6-ledger" do |db|
  db.create_table(:ledgers) do
    primary_key :id

    Integer :year, null: false
    foreign_key :eaccounting_integration_id, :eaccounting_integrations, null: false

    Boolean :is_default, default: false

    unique [:year, :eaccounting_integration_id]
  end

  existing = db[:vouchers].distinct.select(:year, :eaccounting_integration_id).all
  mapping = {}

  existing.each do |key|
    mapping[key] = db[:ledgers].insert(key)
  end

  db.alter_table(:vouchers) do
    add_foreign_key :ledger_id, :ledgers
  end

  mapping.each do |key, id|
    db[:vouchers].where(key).update(ledger_id: id)
  end

  db.alter_table(:vouchers) do
    drop_column :year
    drop_column :eaccounting_integration_id
    set_column_not_null :ledger_id
  end
end

migrate "7-sync-status" do |db|
  db.alter_table(:ledgers) do
    add_column :scheduled_at, DateTime
    add_column :synchronized_at, DateTime
  end
end
