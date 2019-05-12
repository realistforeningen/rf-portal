require 'roda'
require 'tubby'
require 'ippon/form_data'
require 'raven'

class Web < Roda
  DIST_APP = ::Rack::File.new(RFP.webpack_assets_path.to_s)
  ROOT_KEY = Ippon::FormData::DotKey.new

  plugin :sessions, secret: RFP.get(:secret)

  def webpack_path(name)
    full_name = RFP.webpack_manifest.fetch(name)
    "/dist/#{full_name}"
  end

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
      r.run DIST_APP
    end

    @layout = Views::Layout.new
    @layout.head_contents << Tubby.new { |t|
      t.link(rel: "stylesheet", href: webpack_path("main.css"))
    }

    r.on "login" do
      form = Forms::Login.new
      form.key = ROOT_KEY
      page = Pages::Login.new(form)

      r.is method: :get do
        render(page)
      end

      r.is method: :post do
        form.from_params(form_data)
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
      @layout.header_contents << Views::Navigation.new(@current_user)
    end

    r.root do
      if !@current_user
        r.redirect("/login")
      end

      render("Hello #{@current_user.name}!")
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
          page.form.from_params(form_data)
          result = page.form.validate

          if result.valid?
            begin
              Models::User.create(result.value)
            rescue Sequel::UniqueConstraintViolation => err
              page.form.email_unique
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
          page.form.from_params(form_data)
          result = page.form.validate
          
          if result.valid?
            begin
              user.update(result.value)
            rescue Sequel::UniqueConstraintViolation => err
              page.form.email_unique
            else
              r.redirect("/users")
            end
          end

          render(page)
        end
      end
    end
  end
end
