require "./spec_helper"

describe TimezoneFinder do
  it "auto-loads individual files and finds timezone" do
    # Dataset is auto-loaded from on first lookup
    # Test New York, USA
    tz = TimezoneFinder.lookup(40.71, -74.00)
    tz.should_not be_nil
    tz.not_nil!.name.should eq("America/New_York")
  end

  it "auto-loads individual files and finds Kyiv timezone" do
    # Dataset is auto-loaded on first lookup
    # Test Kyiv, Ukraine
    tz = TimezoneFinder.lookup(49.842957, 24.031111)
    tz.should_not be_nil
    tz.not_nil!.name.should eq("Europe/Kyiv")
  end

  it "returns nil or Time::Location for coordinates" do
    # This tests that the lookup doesn't crash and returns a valid type
    # Dataset is auto-loaded on first lookup
    tz = TimezoneFinder.lookup(0.0, 0.0)                 # Should return a timezone or nil
    (tz.nil? || tz.is_a?(Time::Location)).should be_true # Should be nil or a Time::Location
  end
end
