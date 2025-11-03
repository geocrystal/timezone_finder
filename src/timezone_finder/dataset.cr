# Loads the time zone GeoJSON dataset and prepares features for lookup.

require "geojson"
require "json"

module TimezoneFinder
  struct Feature
    getter tzid : String
    getter polygons : Array(Array(Array(Array(Float64)))) # MultiPolygon

    def initialize(@tzid, @polygons)
    end
  end

  @@features : Array(Feature)? = nil
  @@default_directory : String = "data/downloads"

  # Load a GeoJSON FeatureCollection dataset (for backward compatibility)
  def self.load_dataset(path : String)
    json_content = File.read(path)
    collection = GeoJSON::FeatureCollection.from_json(json_content)
    @@features = collection.features.compact_map do |feature|
      props = feature.properties
      next unless props

      tzid_value = props["tzid"]?
      next unless tzid_value
      tzid = tzid_value.as(String)

      geom = feature.geometry
      next unless geom

      polygons = case geom
                 when GeoJSON::Polygon
                   # Convert Polygon coordinates to raw Float64 arrays
                   [geom.coordinates.map do |ring|
                     ring.map(&.coordinates)
                   end]
                 when GeoJSON::MultiPolygon
                   # Convert MultiPolygon coordinates to raw Float64 arrays
                   geom.coordinates.map do |polygon|
                     polygon.map do |ring|
                       ring.map(&.coordinates)
                     end
                   end
                 else
                   next
                 end

      Feature.new(tzid, polygons)
    end
  end

  # Set the default directory for auto-loading individual timezone files
  def self.default_directory=(directory : String)
    @@default_directory = directory
    # Clear cached features so they'll be reloaded from the new directory
    @@features = nil
  end

  # Auto-load individual timezone files from the default directory if not already loaded
  # This is called automatically on first lookup
  def self.ensure_loaded
    return if @@features

    load_from_directory(@@default_directory)
  end

  # Load individual timezone files from a directory
  # Files should be named like "Europe-Kyiv-tz.json" where the timezone name is in the filename
  # The timezone name is extracted from the filename: "Europe-Kyiv-tz.json" -> "Europe/Kyiv"
  private def self.load_from_directory(directory : String)
    features = [] of Feature

    # Load individual files from directory
    Dir.glob(File.join(directory, "*-tz.json")).each do |file_path|
      filename = File.basename(file_path)
      # Extract timezone name from filename: "Europe-Kyiv-tz.json" -> "Europe/Kyiv"
      timezone_name = filename.gsub("-tz.json", "").gsub("-", "/")

      begin
        json_content = File.read(file_path)
        geom = GeoJSON::Object.from_json(json_content)

        next unless geom

        polygons = case geom
                   when GeoJSON::Polygon
                     # Convert Polygon coordinates to raw Float64 arrays
                     [geom.coordinates.map do |ring|
                       ring.map(&.coordinates)
                     end]
                   when GeoJSON::MultiPolygon
                     # Convert MultiPolygon coordinates to raw Float64 arrays
                     geom.coordinates.map do |polygon|
                       polygon.map do |ring|
                         ring.map(&.coordinates)
                       end
                     end
                   else
                     next
                   end

        features << Feature.new(timezone_name, polygons)
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
