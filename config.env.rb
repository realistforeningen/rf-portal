set :database_url, ENV['DATABASE_URL']
set :secret, ENV['SECRET']
set :sentry_dsn, ENV['SENTRY_DSN']

eaccounting = {}
set :eaccounting, eaccounting

insert_eaccounting = ->(name, data) {
  if data.values.any?
    if data.values.all?
      eaccounting[name] = data
    else
      raise "eAccounting environment #{name} incorrectly configured"
    end
  end
}

insert_eaccounting.(:sandbox, {
  client_id: ENV['EACCOUNTING_SANDBOX_CLIENT_ID'],
  client_secret: ENV['EACCOUNTING_SANDBOX_CLIENT_SECRET'],
  redirect_uri: ENV['EACCOUNTING_SANDBOX_REDIRECT_URI'],
})

insert_eaccounting.(:production, {
  client_id: ENV['EACCOUNTING_PRODUCTION_CLIENT_ID'],
  client_secret: ENV['EACCOUNTING_PRODUCTION_CLIENT_SECRET'],
  redirect_uri: ENV['EACCOUNTING_PRODUCTION_REDIRECT_URI'],
})
