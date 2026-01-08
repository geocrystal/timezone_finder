require "http/client"
require "compress/zip"

DATA_DIR    = "data"
DATA_FILE   = "combined-with-oceans.json"
TARGET_FILE = File.join(DATA_DIR, DATA_FILE)
TAG_NAME    = "2025c"
ASSET_NAME  = "timezones-with-oceans.geojson.zip"

# Check if file already exists
if File.exists?(TARGET_FILE)
  puts "✓ #{DATA_FILE} already exists, skipping download"
  exit
end

puts "Downloading #{DATA_FILE} from timezone-boundary-builder releases..."

puts "Downloading from release #{TAG_NAME}..."

# Build release URL
release_url = "https://github.com/evansiroky/timezone-boundary-builder/releases/download/#{TAG_NAME}/#{ASSET_NAME}"

# Create data directory
Dir.mkdir_p(DATA_DIR)

# Create a temporary path
temp_zip_path = File.join(Dir.tempdir, "timezones-#{Random::Secure.hex(4)}.zip")

# Helper function to follow redirects manually and download file
def download_with_redirects(url : String, max_redirects : Int32 = 5) : String
  current_url = url
  redirects_followed = 0

  while redirects_followed < max_redirects
    uri = URI.parse(current_url)
    client = HTTP::Client.new(uri)

    begin
      request_target = uri.path
      request_target += "?#{uri.query}" if uri.query
      response = client.get(request_target)

      # Check if it's a redirect (3xx status codes)
      if response.status_code >= 300 && response.status_code < 400
        location = response.headers["Location"]?
        if location
          redirects_followed += 1
          # Handle both absolute and relative URLs
          if location.starts_with?("http://") || location.starts_with?("https://")
            current_url = location
          else
            # Relative URL - resolve against current URI
            base_uri = uri
            current_url = "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port ? ":#{base_uri.port}" : ""}#{location}"
          end
          next
        else
          raise "Redirect response without Location header"
        end
      elsif response.status_code == 200
        # Read the full body before closing the client
        return response.body
      else
        raise "HTTP request failed with status #{response.status_code}"
      end
    ensure
      client.close
    end
  end

  raise "Too many redirects (#{max_redirects})"
end

begin
  # Download zip file
  puts "Downloading..."
  zip_data = download_with_redirects(release_url)
  File.write(temp_zip_path, zip_data)

  # Extract JSON from zip
  puts "Extracting..."
  Compress::Zip::File.open(temp_zip_path) do |zip|
    entry = zip.entries.find(&.filename.ends_with?(DATA_FILE))
    if entry
      entry.open do |input_io|
        File.open(TARGET_FILE, "w") do |f|
          IO.copy(input_io, f)
        end
      end
    else
      STDERR.puts "✗ Error: Could not find #{DATA_FILE} in zip"
      exit(1)
    end
  end
ensure
  File.delete?(temp_zip_path)
end

# Verify extraction
if File.exists?(TARGET_FILE)
  size = File.size(TARGET_FILE)
  human_size = (size / 1024.0 / 1024.0).round(2)
  puts "✓ Successfully downloaded #{DATA_FILE} (#{human_size} MB)"
else
  STDERR.puts "✗ Error: File extraction failed"
  exit(1)
end
