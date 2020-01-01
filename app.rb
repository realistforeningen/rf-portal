require 'bundler/setup'
require 'appy'
require 'zeitwerk'

RFP = Appy.new do
  @config = {}

  def get(key, &default)
    @config.fetch(key, &default)
  end

  def set(key, value)
    @config[key] = value if !value.nil?
  end

  def has?(key)
    @config.has_key?(key)
  end

  config_file = root + (ENV['CONFIG_FILE'] || 'config.rb')

  if config_file.exist?
    instance_eval(config_file.read, config_file.to_s)
  end

  has(:loader) do
    loader = Zeitwerk::Loader.new
    loader.push_dir(root + 'app')
    loader
  end

  has(:db) do
    require 'sequel'
    Sequel.connect(get(:database_url))
  end

  has(:migrator) do
    require 'ippon/migrator'
    m = Ippon::Migrator.new(db)
    m.load_directory(root + 'app/migrations')
    m
  end

  def migrate
    migrator.apply
  end

  has(:web_app) do
    require_relative 'app/web'
    Web.freeze.app
  end

  has(:webpack_assets_path) do
    root + 'dist'
  end

  has(:webpack_manifest) do
    require 'json'
    JSON.parse((webpack_assets_path + 'manifest.json').read)
  end

  def webpack_path(name)
    full_name = webpack_manifest.fetch(name)
    "/dist/#{full_name}"
  end

  has(:eaccounting_clients) do
    require 'eaccounting_client'

    clients = {}
    get(:eaccounting).each do |name, options|
      clients[name] = EaccountingClient.for_environment(name, **options)
    end if has?(:eaccounting)
    clients
  end

  cmd do |c|
    c.name "console"
    c.summary "runs console in application context"

    c.run do |opts, args|
      require 'pry'
      binding.pry
    end
  end

  cmd do |c|
    c.name "migrate"
    c.summary "run migrations"

    c.run do |opts, args|
      migrate
    end
  end

  cmd do |c|
    c.name "add-user"
    c.summary "create new user"

    c.option nil, :email, "Email address", argument: :required
    c.option :n, :name, "Name", argument: :required
    c.option :p, :password, "Password", argument: :required

    c.run do |opts, args|
      require 'io/console'
      email = opts[:email] || (print("Enter email: "); $stdin.gets.strip)
      name = opts[:name] || (print("Enter name: "); $stdin.gets.strip)
      password = opts[:password] || IO.console.getpass("Enter password: ")
      user = Models::User.create(
        email: email,
        name: name,
        password: password
      )
      puts "Successfully created user (id=#{user.id})"
    end
  end

  cmd do |c|
    c.name "sync-eaccounting"
    
    c.option :e, :env, "Environment", argument: :required, default: "production"
    c.option :n, :name, "Name", argument: :required
    c.option :y, :year, "Year", argument: :required, transform: method(:Integer)

    c.run do |opts, args|
      ledgers = Models::Ledger
        .association_join(:eaccounting_integration)
        .where { eaccounting_integration[:environment] =~ opts[:env] }

      if opts[:name]
        ledgers = ledgers.where { eaccounting_integration[:name] =~ opts[:name] }
      end

      data = ledgers.all

      if data.size != 1
        raise "Couldn't find a single integration"
      end

      ledger = data[0]
      int = ledger.eaccounting_integration

      puts "Syncing #{int.name} (#{int.environment}) for year #{ledger.year}"
      syncer = Eaccounting::Syncer.new(ledger)
      syncer.apply
    end
  end
end

RFP.loader.setup

RFP.cli! if __FILE__ == $0

