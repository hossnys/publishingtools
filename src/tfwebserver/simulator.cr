module TFWeb
  module Simulator
    BASE_URL = "/simulator"

    get "#{BASE_URL}/" do
      render "src/tfwebserver/views/simulator/index.ecr"
    end

    get "#{BASE_URL}/static/*filepath" do |env|
      path = env.params.url["filepath"]
      send_file env, File.join("src/tfwebserver/static/simulator/", path)
    end
  end
end
