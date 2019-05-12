require 'roda'
require 'tubby'
require 'ippon/form_data'

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
    t = Tubby::Renderer.new(target)
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

  route do |r|
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
    end

    r.root do
      if !@current_user
        r.redirect("/login")
      end

      render("Hello #{@current_user.name}!")
    end
  end
end
