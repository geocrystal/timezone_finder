require "../src/timezone_finder"

tz1 = TimezoneFinder.lookup(49.842957, 24.031111)
puts tz1.try(&.name) # => "Europe/Kyiv"

tz2 = TimezoneFinder.lookup(40.71, -74.00)
puts tz2.try(&.name) # => "America/New_York"
