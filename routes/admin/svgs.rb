require 'routes/admin'
require 'rsvg2heroku/pdf_machine'
require 'cuba/send_file'

class Rsvg2heroku::Admin::Svgs < Rsvg2heroku::Admin
  plugin Cuba::SendFile

  define do
    on get, root do
      res.write view('svgs/form')
    end

    on post, param("svg") do |svg_data|
      begin
        file = svg_data[:tempfile].path
        blob = Rsvg2heroku::PDFMachine.convert_svg(file, :pdf)

        res.headers['Content-Type'] = 'application/pdf'
        res.headers['Content-Disposition'] = 'attachment; filename="out.pdf"'

        send_file(blob.path)
      rescue => e
        puts "****** ERROR --- #{e.inspect}"
        res.redirect "/admin/svgs"
      end
    end
  end
end
