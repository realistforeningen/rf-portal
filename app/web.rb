require 'roda'
require 'tubby'
require 'ippon/form_data'
require 'raven'

class Web < Roda
  DIST_APP = ::Rack::File.new(RFP.webpack_assets_path.to_s)
  ROOT_KEY = Ippon::FormData::DotKey.new

  plugin :sessions, secret: RFP.get(:secret)

  def render(content = nil)
    @layout.content = content if content
    target = String.new
    t = RodaRenderer.new(target)
    t.roda_instance = self
    t << @layout
    target
  end

  def body_data
    @body_data ||= if request.content_type == "application/x-www-form-urlencoded"
      Ippon::FormData::URLEncoded.parse(request.body.read)
    else
      Ippon::FormData::URLEncoded.new
    end
  end

  def get_data
    @get_data ||= Ippon::FormData::URLEncoded.parse(request.query_string)
  end

  def form_data
    request.get? ? get_data : body_data
  end

  if sentry_dsn = RFP.has?(:sentry_dsn)
    Raven.configure do |config|
      config.dsn = RFP.get(:sentry_dsn)
    end
  end

  plugin :error_handler do |err|
    if RFP.has?(:sentry_dsn)
      Raven.capture_exception(err)
      render(Pages::Error.new)
    else
      raise err
    end
  end

  plugin :default_headers, "Content-Type" => "text/html;charset=utf-8"

  plugin :route_csrf

  class RodaRenderer < Tubby::Renderer
    attr_accessor :roda_instance

    def current_path
      roda_instance.request.path
    end

    def csrf_form(*args, action: current_path, method:, **opts)
      form(*args, action: action, method: method, **opts) {
        input(
          type: "hidden",
          name: roda_instance.csrf_field,
          value: roda_instance.csrf_token(action, method),
        )
        yield if block_given?
      }
    end
  end

  route do |r|
    check_csrf!

    r.on "dist" do
      response = catch(:halt) do
        r.run DIST_APP
      end

      if request.path.include?(".cache.")
        max_age = 60*60*24*365
        response[1]["Cache-Control"] = "max-age=#{max_age}, public, immutable"
      end

      r.halt(response)
    end

    @layout = Views::Layout.new
    @layout.head_contents << Tubby.new { |t|
      t.link(rel: "stylesheet", href: RFP.webpack_path("main.css"))
    }

    r.on "login" do
      form = Forms::Login.new(ROOT_KEY)
      page = Pages::Login.new(form)

      r.is method: :get do
        render(page)
      end

      r.is method: :post do
        form.from_input(form_data)
        result = form.validate
        if result.valid?
          r.session["user_id"] = result.value[:user].id
          r.redirect("/")
        else
          render(page)
        end
      end
    end

    r.is "logout", method: :post do
      r.session.delete("user_id")
      r.redirect("/")
    end

    if user_id = r.session["user_id"]
      @current_user = Models::User[user_id]
      @layout.navigation = Views::Navigation.new(@current_user)
    end

    r.root do
      if !@current_user
        r.redirect("/login")
      end

      nav = @layout.navigation
      @layout.navigation = nil

      render(Tubby.new { |t|
        t.div(class: "box") {
          t.div(class: "box-body") {
            t << nav
          }
        }
      })
    end

    r.on "me" do
      page = Pages::Me.new
      
      r.is method: :get do
        page.form.from_model(@current_user)
        render(page)
      end

      r.is method: :post do
        page.form.from_input(form_data)
        result = page.form.validate

        if result.valid?
          data = result.value
          data.delete(:password) if data[:password].nil?
          begin
            @current_user.update(data)
          rescue Sequel::UniqueConstraintViolation => err
            page.form.mark_used_email
          else
            r.redirect("/me")
          end
        end

        render(page)
      end
    end

    r.on "users" do
      r.is method: :get do
        render(Pages::Users.new)
      end

      r.is "new" do
        page = Pages::UserNew.new

        r.is method: "get" do
          render(page)
        end

        r.is method: :post do
          page.form.from_input(form_data)
          result = page.form.validate

          if result.valid?
            begin
              Models::User.create(result.value)
            rescue Sequel::UniqueConstraintViolation => err
              page.form.mark_used_email
            else
              r.redirect("/users")
            end
          end

          render(page)
        end
      end

      r.on Integer, "edit" do |id|
        user = Models::User[id]
        page = Pages::UserEdit.new(user)

        r.is method: "get" do
          page.form.from_model(user)
          render(page)
        end

        r.is method: "post" do
          page.form.from_input(form_data)
          result = page.form.validate
          
          if result.valid?
            begin
              user.update(result.value)
            rescue Sequel::UniqueConstraintViolation => err
              page.form.mark_used_email
            else
              r.redirect("/users")
            end
          end

          render(page)
        end
      end
    end

    r.on "ledgers" do
      r.is method: :get do
        page = Pages::Ledgers.new
        render(page)
      end

      r.on Integer do |id|
        ledger = Models::Ledger[id]

        r.is method: :get do
          page = Pages::Transactions.new(ledger)
          page.form.from_input(get_data)
          page.load!
          render(page)
        end

        r.is "sync", method: :get do
          page = Pages::LedgerSync.new(ledger)
          render(page)
        end

        r.is "sync", method: :post do
          RFP.db.transaction do
            Jobs::EaccountingSyncer.enqueue(ledger.id)
            ledger.update(scheduled_at: Time.now)
          end
          r.redirect("/ledgers/#{ledger.id}")
        end
      end
    end

    r.is "callback", method: :get do
      environment = get_data.fetch("state")
      client = RFP.eaccounting_clients.fetch(environment.to_sym)
      token = client.get_token(get_data.fetch("code"))
      settings = token.get("/v2/companysettings").parsed
      company_number = settings["CorporateIdentityNumber"]
      integration = Models::EaccountingIntegration.find_or_create(
        environment: environment,
        name: company_number
      )
      integration.update_from_token(token)
      r.redirect("/eaccounting")
    end

    r.on "eaccounting" do
      r.is method: :get do
        render(Pages::Eaccounting.new)
      end

      r.is "authorize", String, method: :get do |environment|
        client = RFP.eaccounting_clients.fetch(environment.to_sym)
        r.redirect(client.authorize_url(state: environment))
      end
    end
  end
end
