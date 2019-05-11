require 'roda'
require 'tubby'

class Web < Roda
  DIST_APP = ::Rack::File.new(RFP.webpack_assets_path.to_s)

  def webpack_path(name)
    full_name = RFP.webpack_manifest.fetch(name)
    "/dist/#{full_name}"
  end

  route do |r|
    r.on "dist" do
      r.run DIST_APP
    end

    r.root do
      Tubby.new { |t|
        t.doctype!
        t.link(rel: "stylesheet", href: webpack_path("main.css"))
        t.p("Webapp is running!", class: "text-green-700 text-xl")
      }.to_s
    end
  end
end
