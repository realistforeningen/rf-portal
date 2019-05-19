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

  has(:eaccounting_sandbox) do
    require 'eaccounting_client'

    EaccountingClient.new(
      site: "https://eaccountingapi-sandbox.test.vismaonline.com",
      authorize_url: "https://identity-sandbox.test.vismaonline.com/connect/authorize",
      token_url: "https://identity-sandbox.test.vismaonline.com/connect/token",
      redirect_uri: "https://localhost:44300/callback",
      **get(:eaccounting_sandbox),
    )
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
end

RFP.loader.setup

RFP.cli! if __FILE__ == $0

