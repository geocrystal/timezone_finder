# Performs time zone lookup using loaded dataset.

require "polygon_contains"

module TimezoneFinder
  def self.lookup(lat : Float64, lon : Float64) : Time::Location?
    # Auto-load dataset on first call if not already loaded
    ensure_loaded
    point = {lon, lat} # Convert to tuple as expected by PolygonContains

    @@features.not_nil!.each do |feature|
      # For MultiPolygon, check if point is in ANY polygon
      # Each polygon can have multiple rings: ring 0 is outer boundary, rings 1+ are holes
      feature.polygons.each do |polygon|
        # Quick bounding box check to skip polygons that clearly don't contain the point
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

        # Skip if point is clearly outside bounding box
        next if point[0] < min_lon || point[0] > max_lon || point[1] < min_lat || point[1] > max_lat

        # Convert polygon from Array(Array(Array(Float64))) to Array(Array(Point))
        # where each coordinate [lon, lat] becomes {lon, lat}
        # PolygonContains expects: ring 0 = outer boundary, rings 1+ = holes
        converted_polygon = polygon.map do |ring|
          ring.map do |coord|
            {coord[0], coord[1]} # Convert [lon, lat] to {lon, lat}
          end
        end

        # Check if point is in this polygon using PolygonContains
        if PolygonContains.contains?(converted_polygon, point)
          return Time::Location.load(feature.tzid)
        end
      end
    end
    nil
  end
end
