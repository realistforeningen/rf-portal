require 'bundler/setup'
require 'appy'

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
end

RFP.cli! if __FILE__ == $0

