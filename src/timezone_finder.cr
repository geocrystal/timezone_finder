# Offline time zone lookup by latitude and longitude.
#
# Example:
#
# ```
# require "timezone_finder"
# tz = TimezoneFinder.lookup(49.842957, 24.031111)
# puts tz.try(&.name) # => "Europe/Kyiv"
# # Returns Time::Location? which can be used directly with Time
# ```
#
# The dataset is automatically loaded from the GeoJSON file on the first lookup
# and cached for subsequent calls.

require "./timezone_finder/dataset"
require "./timezone_finder/lookup"

# Main module
module TimezoneFinder
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  # Methods are defined in dataset.cr and lookup.cr
end
