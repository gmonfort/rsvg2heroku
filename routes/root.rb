require "rack/protection"
require 'rack/ssl'
require "routes/admin"

class Rsvg2heroku::Root < Rsvg2heroku::App
  use Rack::Deflater

  if ENV["RACK_ENV"] == "production"
    use Rack::SSL
  end

  if ENV["RACK_ENV"] == "production"
    use Rack::Static, urls: "/assets",
                      root: "./public"
  end

  if ENV["CARRIERWAVE_STORAGE"] == "file"
    use Rack::Static, urls: ["/uploads"], root: "./public"
  end

  use Rack::Static, urls: ["/images"],
                    root: "./public"

  use Rack::Protection::FrameOptions
  use Rack::Protection::HttpOrigin
  use Rack::Protection::IPSpoofing
  use Rack::Protection::PathTraversal
  use Rack::Protection::RemoteReferrer
  use Rack::Protection::XSSHeader

  use Rack::MethodOverride

  define do
    on "admin" do
      run Rsvg2heroku::Admin
    end
  end
end
