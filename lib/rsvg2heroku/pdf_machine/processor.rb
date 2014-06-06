require 'securerandom'
require 'tempfile'
require "rsvg2"

module Rsvg2heroku
  module PDFMachine
    class Processor
      def initialize(input, output_format, options)
        @svg    = input
        @format = output_format.to_sym

        setup_options options
      end

      def process
        setup
        case @format
          when :jpeg, :jpg, :png  then render_image
          when :pdf, :ps          then render
          else raise PDFMachine::UnsupportedFormatError, "Invalid output format: %s" % @format.to_s
        end
      end

      private

      def handle
        @handle ||= (input_type == :data) ? RSVG::Handle.new_from_data(@svg) : RSVG::Handle.new_from_file(@svg)
      end

      def input_type
        (@svg.is_a?(String) && File.exists?(@svg)) ? :file : :data
      end

      def render
        @context = create_context @options[:output_file]
        @context.target.finish
        File.new @options[:output_file]
      end

      def render_image
        @context = create_context Cairo::FORMAT_ARGB32

        temp = Tempfile.new("svg2")
        @context.target.write_to_png(temp.path)
        @context.target.finish
        @pixbuf = Gdk::Pixbuf.new(temp.path)
        @pixbuf.save(@options[:output_file], @format.to_s)

        File.new @options[:output_file]
      end

      def setup
        dim     = handle.dimensions
        @ratio  = @options[:ratio]
        @width  = dim.width * @ratio
        @height = dim.height * @ratio

        surface_class_name = case @format
          when :jpg, :jpeg, :png  then "ImageSurface"
          when :ps                then "PSSurface"
          when :pdf               then "PDFSurface"
        end
        @surface_class = Cairo.const_get(surface_class_name)
      end

      def create_context(arg)
        # portrait
        surface = @surface_class.new(arg, @height, @width)
        context = Cairo::Context.new(surface)

        # rotate 90 degrees clockwise (in radians)
        context.rotate(Math::PI/2)
        context.translate(0, -@height)

        context.render_rsvg_handle(handle)
        context
      end

      def setup_options(options)
        # TODO: check working_dir, output_name, etc
        @options = options
        @options[:output_name] += '-' + SecureRandom.hex(16)
        @options[:output_file] ||= File.join(@options[:working_dir], @options[:output_name] + '.' + @format.to_s)
      end

      def perform_checks
        check_cairo
        check_svg_file
      end

      def check_svg_file
        raise FileNotFoundError   unless File.exists? File.expand_path @svg
        raise InvalidSvgFileError unless File.extname(@svg)[1..-1].downcase =~ /^svg$/
      end

      def check_cairo
        raise CairoError.new("Cairo library not found") if ! RSVG.cairo_available?
      end
    end
  end
end
