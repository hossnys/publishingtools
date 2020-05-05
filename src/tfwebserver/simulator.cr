module TFWeb
  module Simulator
    SIM_BASR_URL = "/simulator"

    get "#{SIM_BASR_URL}/" do
      render "src/tfwebserver/views/simulator/index.ecr"
    end

    get "#{SIM_BASR_URL}/static/*filepath" do |env|
      path = env.params.url["filepath"]
      send_file env, File.join("src/tfwebserver/static/simulator/", path)
    end
  end
end
