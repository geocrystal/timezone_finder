# Offline time zone lookup by latitude and longitude.
#
# Example:
#   tz = TimezoneFinder.lookup(49.842957, 24.031111)
#   puts tz.try(&.name) # => "Europe/Kyiv"
#   # Returns Time::Location? which can be used directly with Time
#
# The dataset is automatically loaded from data/downloads on the first lookup
# and cached for subsequent calls.

require "./timezone_finder/dataset"
require "./timezone_finder/lookup"

# Main module
module TimezoneFinder
  VERSION = "0.1.0"

  # The dataset is automatically loaded from individual timezone files
  # in the data/downloads directory on the first lookup call.
  #
  # Files should be named like "Europe-Kyiv-tz.json" where the timezone name
  # is extracted from the filename (e.g., "Europe-Kyiv-tz.json" -> "Europe/Kyiv")
  #
  # To change the default directory:
  #   TimezoneFinder::Dataset.default_directory = "path/to/directory"
  #
  # Methods are defined in dataset.cr and lookup.cr
end
