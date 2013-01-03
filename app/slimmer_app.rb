require 'json'

class SlimmerApp
  POST_BODY = 'rack.input'.freeze

  def call(env)
    if env['REQUEST_METHOD'] !~ %r{POST}i
      [406, {"Content-Type" => "text/plain"}, ["Not Acceptable"]]
    elsif env['CONTENT_TYPE'] =~ %r{application/json}i
      encoded_body = env[POST_BODY].read
      body = JSON.parse(encoded_body)
      [200, {"Content-Type" => "text/html"}, [body.inspect]]
    else
      [404, {"Content-Type" => "text/plain"}, ["I prefer JSON"]]
    end    
  end
end
