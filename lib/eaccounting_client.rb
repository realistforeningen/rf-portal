require 'oauth2'

class EaccountingClient
  DEFAULT_OPTIONS = {
    sandbox: {
      site: "https://eaccountingapi-sandbox.test.vismaonline.com",
      authorize_url: "https://identity-sandbox.test.vismaonline.com/connect/authorize",
      token_url: "https://identity-sandbox.test.vismaonline.com/connect/token",
    },

    production: {
      site: "https://eaccountingapi.vismaonline.com",
      authorize_url: "https://identity.vismaonline.com/connect/authorize",
      token_url: "https://identity.vismaonline.com/connect/token",
    },
  }

  def self.for_environment(name, **options)
    default_options = DEFAULT_OPTIONS.fetch(name)
    new(**default_options, **options)
  end

  def initialize(site:, client_id:, client_secret:, authorize_url:, token_url:, redirect_uri:)
    @site = site
    @client_id = client_id
    @client_secret = client_secret
    @authorize_url = authorize_url
    @token_url = token_url
    @redirect_uri = redirect_uri
  end

  def oauth2
    @oauth2 ||= OAuth2::Client.new(
      @client_id,
      @client_secret,
      site: @site,
      authorize_url: @authorize_url,
      token_url: @token_url,
      auth_scheme: :basic_auth,
    )
  end

  def authorize_url(state: nil)
    oauth2.auth_code.authorize_url(
      redirect_uri: @redirect_uri,
      scope: 'offline_access ea:api ea:accounting ea:sales ea:purchase',
      state: state,
    )
  end

  def get_token(code)
    oauth2.auth_code.get_token(code, redirect_uri: @redirect_uri)
  end

  def reuse_token(access_token)
    OAuth2::AccessToken.from_hash(oauth2, access_token: access_token)
  end

  def refresh_token(refresh_token)
    oauth2.get_token(grant_type: "refresh_token", refresh_token: refresh_token)
  end
end