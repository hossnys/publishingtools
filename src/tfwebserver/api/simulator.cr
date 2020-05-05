module TFWeb
  module API
    module Simulator
      SIM_BASE_URL     = "/api/simulator"
      SIM_DATASITE_URL = "https://github.com/threefoldfoundation/simulator_export"

      class Options
        include JSON::Serializable

        property hardware_type : String
        property growth : Int64
        property token_price : String
        property unit_price_range : Int32
      end

      def self.create_simulator_wiki(options : Options)
        hardware_type = options.hardware_type
        growth = options.growth
        token_price = options.token_price
        unit_price_range = options.unit_price_range

        params = [hardware_type, "#{growth}", "tft_#{token_price}", "price_#{unit_price_range}"]
        name = "sim_" + params.join("_")

        unless WebServer.wikis.has_key?(name)
          sub_path = File.join("tfsimulator/export", params.join("/"))

          wikiobj = Wiki.new
          wikiobj.name = name
          wikiobj.url = SIM_DATASITE_URL
          wikiobj.srcdir = sub_path

          begin
            wikiobj.prepare_on_fs
          rescue
            raise "data path cannot be found '#{sub_path}'"
          end

          WebServer.wikis[wikiobj.name] = wikiobj
          WebServer.prepare_wiki(wikiobj)
        end

        name
      end

      post SIM_BASE_URL do |env|
        begin
          name = create_simulator_wiki(Options.from_json(env.request.body.not_nil!))
          env.response.content_type = "application/json"
          data = {"name" => name}.to_json
          env.response.print data
        rescue exc
          puts exc.message.colorize(:red)
          env.response.status_code = 404
          error = {"message" => "data cannot be found for current options"}.to_json
          env.response.print error
        ensure
          env.response.close
        end
      end
    end
  end
end
