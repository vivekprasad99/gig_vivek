import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';

class PickResult {
  PickResult({
    this.placeId,
    this.geometry,
    this.formattedAddress,
    this.types,
    this.addressComponents,
    this.adrAddress,
    this.formattedPhoneNumber,
    this.id,
    this.reference,
    this.icon,
    this.name,
    this.openingHours,
    this.photos,
    this.internationalPhoneNumber,
    this.priceLevel,
    this.rating,
    this.scope,
    this.url,
    this.vicinity,
    this.utcOffset,
    this.website,
    this.reviews,
    this.city,
    this.postalCode,
    this.state,
    this.latitude,
    this.longitude,
  });

  final String? placeId;
  final Geometry? geometry;
  final String? formattedAddress;
  final List<String>? types;
  final List<AddressComponent>? addressComponents;

  // Below results will not be fetched if 'usePlaceDetailSearch' is set to false (Defaults to false).
  final String? adrAddress;
  final String? formattedPhoneNumber;
  final String? id;
  final String? reference;
  final String? icon;
  final String? name;
  final OpeningHoursDetail? openingHours;
  final List<Photo>? photos;
  final String? internationalPhoneNumber;
  final PriceLevel? priceLevel;
  final num? rating;
  final String? scope;
  final String? url;
  final String? vicinity;
  final num? utcOffset;
  final String? website;
  final List<Review>? reviews;
  final String? city;
  final String? postalCode;
  final String? state;
  final double? latitude;
  final double? longitude;

  factory PickResult.fromGeocodingResult(GeocodingResult result) {
    var city = '';
    var postcode = '';
    var state = '';
    if(result.addressComponents.isNotEmpty && result.addressComponents[0].types.isNotEmpty) {
      for(var component in result.addressComponents) {
        var componentType = component.types[0];
        switch (componentType) {
          case "locality":
            city = component.longName;
            break;
          case "postal_code":
            postcode = component.longName;
            break;
          case "administrative_area_level_1":
            state = component.longName;
            break;
        }
      }
    }
    return PickResult(
      placeId: result.placeId,
      geometry: result.geometry,
      formattedAddress: result.formattedAddress,
      types: result.types,
      addressComponents: result.addressComponents,
      city: city,
      postalCode: postcode,
      state: state,
      latitude: result.geometry.location.lat,
      longitude: result.geometry.location.lng,
    );
  }

  factory PickResult.fromPlaceDetailResult(PlaceDetails result) {
    var city = '';
    var postcode = '';
    var state = '';
    if(result.addressComponents.isNotEmpty && result.addressComponents[0].types.isNotEmpty) {
      for(var component in result.addressComponents) {
        var componentType = component.types[0];
        switch (componentType) {
          case "postal_town":
            city = component.longName;
            break;
          case "postal_code":
            postcode = component.longName;
            break;
          case "administrative_area_level_1":
            state = component.longName;
            break;
        }
      }
    }
    return PickResult(
      placeId: result.placeId,
      geometry: result.geometry,
      formattedAddress: result.formattedAddress,
      types: result.types,
      addressComponents: result.addressComponents,
      adrAddress: result.adrAddress,
      formattedPhoneNumber: result.formattedPhoneNumber,
      id: result.id,
      reference: result.reference,
      icon: result.icon,
      name: result.name,
      openingHours: result.openingHours,
      photos: result.photos,
      internationalPhoneNumber: result.internationalPhoneNumber,
      priceLevel: result.priceLevel,
      rating: result.rating,
      scope: result.scope,
      url: result.url,
      vicinity: result.vicinity,
      utcOffset: result.utcOffset,
      website: result.website,
      reviews: result.reviews,
      city: city.isNotEmpty ? city : result.name,
      postalCode: postcode,
      state: state,
      latitude: result.geometry?.location.lat,
      longitude: result.geometry?.location.lng,
    );
  }
}
