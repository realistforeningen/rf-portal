require 'roda'
require 'tubby'

class Web < Roda
  DIST_APP = ::Rack::File.new(RFP.webpack_assets_path.to_s)

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

  route do |r|
    r.on "dist" do
      r.run DIST_APP
    end

    @layout = Views::Layout.new
    @layout.head_contents << Tubby.new { |t|
      t.link(rel: "stylesheet", href: webpack_path("main.css"))
    }

    r.root do
      render("Hello world!")
    end
  end
end
