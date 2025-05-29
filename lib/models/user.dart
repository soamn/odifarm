
class UserModel {
  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? addressline1;
  final String? addressline2;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? countryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.role = 'USER',
    this.firstName,
    this.lastName,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.addressline1,
    this.addressline2,
    this.city,
    this.street,
    this.state,
    this.zipCode,
    this.countryId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    role: json['role'] ?? 'USER',
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    addressline1: json['address_line1'],
    addressline2: json['address_line2'],
    state: json['state'],
    street: json['street'],
    city: json['city'],
    countryId: json['countryId'],
    zipCode: json['zipCode'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'address_line_1': addressline1,
    'address_line_2': addressline2,
    'street': street,
    'state': state,
    'city': city,
    'zipCode': zipCode,
    'countryId': countryId,
  };
  
}
