require "cuba/render"

class Rsvg2heroku::Admin < Rsvg2heroku::App
  plugin Cuba::Render

  settings[:render][:views] = "views/admin"
    on "svgs" do
      run Rsvg2heroku::Admin::Svgs
    end

    on get, root do
      res.write view("index")
    end
  end
end

require "routes/admin/svgs"
