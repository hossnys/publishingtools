module TFWeb
  module API
    module Simulator
      include TFWeb::Simulator

      SIM_API_BASE_URL = "/:name/api" + SIM_BASE_URL

      get "#{SIM_API_BASE_URL}/options" do |env|
        env.response.content_type = "application/json"
        TFWeb::Simulator.get_available_options.to_json
      end

      post SIM_API_BASE_URL do |env|
        begin
          name = TFWeb::Simulator.create_simulator_wiki(Options.from_json(env.request.body.not_nil!))
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
