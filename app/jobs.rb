require 'que'
Que.connection = RFP.db

Que.error_notifier = proc { |error| 
  if RFP.has?(:sentry_dsn)
    Raven.capture_exception(err)
  end
}

module Jobs
end