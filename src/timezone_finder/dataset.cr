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
  @@dataset_file : String = "data/combined-with-oceans-1970.json"

  # Auto-load the timezone file if not already loaded
  # This is called automatically on first lookup
  def self.ensure_loaded
    return if @@features

    load_from_file(@@dataset_file)
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

  # Load timezone features from the GeoJSON FeatureCollection file
  # Expected format: {"type": "FeatureCollection", "features": [...]}
  # Each feature has: {"type": "Feature", "properties": {"tzid": "..."}, "geometry": {...}}
  # Uses optimized direct JSON parsing to avoid GeoJSON library overhead
  private def self.load_from_file(file_path : String)
    features = [] of Feature

    begin
      json_content = File.read(file_path)
      json = JSON.parse(json_content)

      # Validate FeatureCollection structure
      type = json["type"]?
      unless type && type.as_s == "FeatureCollection"
        raise "Invalid file format: expected FeatureCollection, got #{type}"
      end

      features_json = json["features"]?
      raise "Missing features array" unless features_json
      features_array = features_json.as_a

      # Process each feature
      features_array.each do |feature_json|
        feature_hash = feature_json.as_h

        # Extract timezone ID from properties.tzid
        properties_json = feature_hash["properties"]?
        next unless properties_json
        properties = properties_json.as_h
        tzid_json = properties["tzid"]?
        next unless tzid_json
        tzid = tzid_json.as_s

        # Extract geometry
        geometry_json = feature_hash["geometry"]?
        next unless geometry_json
        geometry = geometry_json.as_h

        geom_type_json = geometry["type"]?
        next unless geom_type_json
        geom_type = geom_type_json.as_s
        coords_json = geometry["coordinates"]?
        next unless coords_json

        # Convert coordinates to Float64 arrays based on geometry type
        polygons = case geom_type
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
                     next # Skip unsupported geometry types
                   end

        # Precompute bounding boxes for each polygon
        bounding_boxes = compute_bounding_boxes(polygons)
        features << Feature.new(tzid, polygons, bounding_boxes)
      end
    rescue ex
      raise "Failed to load file: #{ex.message}"
    end

    @@features = features
  end

  def self.features : Array(Feature)
    ensure_loaded
    @@features.not_nil!
  end
end
