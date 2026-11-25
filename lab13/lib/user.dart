/// One user from jsonplaceholder.typicode.com/users.
///
/// User, Address and Geo are the three levels of the same JSON object,
/// so they stay together in one file.
class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Address address;

  /// A user typed in the app, before the server gave it an id.
  factory User.draft(String name) => User(
    id: 0,
    name: name,
    username: name.toLowerCase().replaceAll(' ', '.'),
    email: '',
    phone: '',
    website: '',
    address: const Address(
      street: '',
      suite: '',
      city: '—',
      zipcode: '',
      geo: Geo(lat: 0, lng: 0),
    ),
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    website: json['website'] as String,
    address: Address.fromJson(json['address'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address.toJson(),
  };
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

class Geo {
  const Geo({required this.lat, required this.lng});

  final double lat;
  final double lng;

  // The API sends coordinates as strings: "lat": "-37.3159".
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  Map<String, dynamic> toJson() => {'lat': '$lat', 'lng': '$lng'};
}
