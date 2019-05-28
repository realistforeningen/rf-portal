require 'argon2'

module Models
  class EaccountingIntegration < Sequel::Model
    def client
      @client ||= RFP.eaccounting_clients.fetch(environment.to_sym) do
        raise "Unknown environment: #{environment}"
      end
    end

    def token
      if token_expires_at - Time.now < 60*3
        # Make sure we have a valid token for three minutes
        get_fresh_token
      end

      client.reuse_token(access_token)
    end

    def update_from_token(token)
      update(
        access_token: token.token,
        refresh_token: token.refresh_token,
        token_expires_at: Time.at(token.expires_at),
      )
    end

    def get_fresh_token
      new_token = client.refresh_token(refresh_token)
      update_from_token(new_token)
    end
  end
end
