require "./init"
require "routes/root"

use Rack::Auth::Basic, "gimmie the pass! :)" do |username, password|
  username == "rsvg" && password == "heroku"
end

run Rsvg2heroku::Root
