enum LocationPickTarget { pickup, drop }

class LocationPickArgs {
  const LocationPickArgs(this.target);

  final LocationPickTarget target;
}
