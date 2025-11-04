# Loads the time zone GeoJSON dataset and prepares features for lookup.

require "json"

module TimezoneFinder
  struct BoundingBox
    getter min_lon : Float64
    getter max_lon : Float64
    getter min_lat : Float64
    getter max_lat : Float64

    def initialize(@min_lon, @max_lon, @min_lat, @max_lat)
    end

    def contains?(lon : Float64, lat : Float64) : Bool
      lon >= @min_lon && lon <= @max_lon && lat >= @min_lat && lat <= @max_lat
    end
  end

  struct Feature
    getter tzid : String
    getter polygons : Array(Array(Array(Array(Float64)))) # MultiPolygon
    getter bounding_boxes : Array(BoundingBox)            # Precomputed bounding box for each polygon

    def initialize(@tzid, @polygons, @bounding_boxes)
    end
  end

  @@features : Array(Feature)? = nil
  @@default_directory : String = "data"

  # Auto-load individual timezone files from the default directory if not already loaded
  # This is called automatically on first lookup
  def self.ensure_loaded
    return if @@features

    load_from_directory(@@default_directory)
  end

  # Compute bounding box for a polygon
  private def self.compute_bounding_box(polygon : Array(Array(Array(Float64)))) : BoundingBox
    min_lon = Float64::MAX
    max_lon = Float64::MIN
    min_lat = Float64::MAX
    max_lat = Float64::MIN

    polygon.each do |ring|
      ring.each do |coord|
        lon, lat = coord[0], coord[1]
        min_lon = lon if lon < min_lon
        max_lon = lon if lon > max_lon
        min_lat = lat if lat < min_lat
        max_lat = lat if lat > max_lat
      end
    end

    BoundingBox.new(min_lon, max_lon, min_lat, max_lat)
  end

  # Compute bounding boxes for all polygons
  private def self.compute_bounding_boxes(polygons : Array(Array(Array(Array(Float64))))) : Array(BoundingBox)
    polygons.map { |polygon| compute_bounding_box(polygon) }
  end

  # Load individual timezone files from a directory
  # Files should be named like "Europe-Kyiv-tz.json" where the timezone name is in the filename
  # The timezone name is extracted from the filename: "Europe-Kyiv-tz.json" -> "Europe/Kyiv"
  # Uses optimized direct JSON parsing to avoid GeoJSON library overhead (1.5x faster)
  private def self.load_from_directory(directory : String)
    features = [] of Feature

    # Load individual files from directory
    Dir.glob(File.join(directory, "*-tz.json")).each do |file_path|
      filename = File.basename(file_path)
      # Extract timezone name from filename: "Europe-Kyiv-tz.json" -> "Europe/Kyiv"
      timezone_name = filename.gsub("-tz.json", "").gsub("-", "/")

      begin
        json_content = File.read(file_path)

        # Parse JSON once and extract coordinates directly (faster than GeoJSON library)
        json = JSON.parse(json_content)
        coords_json = json["coordinates"]?
        next unless coords_json

        # Convert directly to Float64 arrays without creating Coordinates objects
        # This skips validation and object creation overhead
        polygons = case json["type"]?
                   when "Polygon"
                     # Polygon: [[[lon,lat], [lon,lat], ...]]
                     [coords_json.as_a.map do |ring|
                       ring.as_a.map do |coord|
                         [coord.as_a[0].as_f, coord.as_a[1].as_f]
                       end
                     end]
                   when "MultiPolygon"
                     # MultiPolygon: [[[[lon,lat], ...]], [[[lon,lat], ...]]]
                     coords_json.as_a.map do |polygon|
                       polygon.as_a.map do |ring|
                         ring.as_a.map do |coord|
                           [coord.as_a[0].as_f, coord.as_a[1].as_f]
                         end
                       end
                     end
                   else
                     next
                   end

        # Precompute bounding boxes for each polygon
        bounding_boxes = compute_bounding_boxes(polygons)
        features << Feature.new(timezone_name, polygons, bounding_boxes)
      rescue ex
        # Skip files that can't be parsed
        next
      end
    end

    @@features = features
  end

  def self.features : Array(Feature)
    ensure_loaded
    @@features.not_nil!
  end
end
