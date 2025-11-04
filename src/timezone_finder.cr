# Offline time zone lookup by latitude and longitude.
#
# Example:
#   tz = TimezoneFinder.lookup(49.842957, 24.031111)
#   puts tz.try(&.name) # => "Europe/Kyiv"
#   # Returns Time::Location? which can be used directly with Time
#
# The dataset is automatically loaded from the GeoJSON file on the first lookup
# and cached for subsequent calls.

require "./timezone_finder/dataset"
require "./timezone_finder/lookup"

# Main module
module TimezoneFinder
  VERSION = "0.1.0"

  # The dataset is automatically loaded from the combined-with-oceans.json file
  # on the first lookup call. The file contains a GeoJSON FeatureCollection with
  # timezone boundaries (consistent since 1970), where each feature has properties.tzid and geometry.
  #
  # Methods are defined in dataset.cr and lookup.cr
end
