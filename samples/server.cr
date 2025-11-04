require "http/server"
require "json"
require "../src/timezone_finder"

# Simple HTTP server that provides timezone lookup via REST API
# Run with: crystal run samples/server.cr

PORT = 3000

server = HTTP::Server.new do |context|
  request = context.request
  response = context.response

  response.headers.add "X-Powered-By", "Crystal"
  response.content_type = "application/json"

  # Only handle GET requests to /timezone endpoint
  if request.method == "GET" && request.path == "/timezone"
    # Parse query parameters
    lat_param = request.query_params["lat"]?
    lon_param = request.query_params["lon"]?

    # Validate parameters
    if lat_param.nil? || lon_param.nil?
      response.status_code = 400

      response.print({
        "error" => "Missing required parameters: 'lat' and 'lon' are required",
      }.to_json)
      next
    end

    begin
      # Parse latitude and longitude
      lat = lat_param.to_f
      lon = lon_param.to_f

      # Validate coordinate ranges
      if lat < -90.0 || lat > 90.0
        response.status_code = 400

        response.print({
          "error" => "Invalid latitude: must be between -90 and 90",
        }.to_json)
        next
      end

      if lon < -180.0 || lon > 180.0
        response.status_code = 400

        response.print({
          "error" => "Invalid longitude: must be between -180 and 180",
        }.to_json)
        next
      end

      # Lookup timezone
      tz = TimezoneFinder.lookup(lat, lon)

      if tz
        response.status_code = 200

        local_time = Time.local(tz)
        zone = local_time.zone
        offset = zone.offset

        response.print({
          "timezone"   => tz.name,
          "latitude"   => lat,
          "longitude"  => lon,
          "offset"     => zone.format,
          "local_time" => local_time.to_s("%Y-%m-%d %H:%M:%S"),
        }.to_json)
      else
        response.status_code = 404

        response.print({
          "error"     => "No timezone found for the given coordinates",
          "latitude"  => lat,
          "longitude" => lon,
        }.to_json)
      end
    rescue ex
      response.status_code = 400

      response.print({
        "error" => "Invalid parameter format: #{ex.message}",
      }.to_json)
    end
  else
    # Return 404 for other paths
    response.status_code = 404

    response.print({
      "error" => "Not found. Use GET /timezone?lat=<latitude>&lon=<longitude>",
    }.to_json)
  end
end

start_time = Time.monotonic
puts "Loading timezone data..."
TimezoneFinder.ensure_loaded
load_time = Time.monotonic - start_time
puts "   Loaded in #{load_time.total_milliseconds.round(2)} ms"

address = server.bind_tcp PORT
puts "Timezone Finder API Server"
puts "Listening on http://#{address}"
puts "Example: http://#{address}/timezone?lat=49.842957&lon=24.031111"
puts "Press Ctrl+C to stop"
server.listen
