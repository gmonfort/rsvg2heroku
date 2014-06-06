module Rsvg2heroku
  module PDFMachine
    class Config
      attr_accessor :debug, :output_name, :ratio, :working_dir

      def initialize
        @debug        = false
        @output_name  = "out"
        @ratio        = 1.0
        @working_dir  = "/tmp"
      end

      def to_hash
        Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
      end
    end
  end
end

