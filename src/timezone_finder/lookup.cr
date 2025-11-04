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
      feature.polygons.each_with_index do |polygon, polygon_idx|
        # Use precomputed bounding box to skip polygons that clearly don't contain the point
        bbox = feature.bounding_boxes[polygon_idx]
        next unless bbox.contains?(point[0], point[1])

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
          return Time::Location.load?(feature.tzid)
        end
      end
    end
    nil
  end
end
