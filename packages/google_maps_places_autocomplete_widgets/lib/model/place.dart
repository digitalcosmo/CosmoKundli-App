class Place {
  String? name;
  String? formattedAddress;
  String? formattedAddressZipPlus4;
  String? streetAddress;
  String? streetNumber;
  String? streetShort;
  String? street;
  String? city;
  String? county;
  String? state;
  String? stateShort;
  String? zipCode;
  String? zipCodeSuffix;
  String? zipCodePlus4;
  String? vicinity;
  String? country;
  double? lat;
  double? lng;
  /// Offset from UTC in minutes (Places Details `utc_offset`).
  int? utcOffset;

  Place({
    this.name,
    this.formattedAddress,
    this.formattedAddressZipPlus4,
    this.streetAddress,
    this.streetNumber,
    this.streetShort,
    this.street,
    this.city,
    this.county,
    this.state,
    this.stateShort,
    this.zipCode,
    this.zipCodeSuffix,
    this.zipCodePlus4,
    this.vicinity,
    this.country,
    this.lat,
    this.lng,
    this.utcOffset,
  });

  @override
  String toString() {
    return 'Place(name:$name formattedAddressZipPlus4:$formattedAddressZipPlus4 formattedAddress:$formattedAddress streetNumber: $streetNumber, streetShort: $streetShort street: $street, city: $city, state:$state startShort:$stateShort county: $county, zipCode: $zipCode zipCodeSuffix: $zipCodeSuffix zipCodePlus4:$zipCodePlus4)';
  }
}
