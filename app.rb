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

  cmd(:console) do
    require 'pry'
    binding.pry
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

  cmd(:migrate) do
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
end

RFP.loader.setup

RFP.cli! if __FILE__ == $0

