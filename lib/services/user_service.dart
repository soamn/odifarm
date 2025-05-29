import 'package:odifarm/models/country.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:odifarm/models/user.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> fetchUserData(String email) async {
    final response = await supabase
        .from('User')
        .select('*')
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  Future<bool> createUser(String email, String id) async {
    final response = await supabase.from('User').insert({
      'id': id,
      'email': email,
    });

    if (response.error != null) {
      throw Exception("Failed to create user: ${response.error!.message}");
    }
    return true;
  }

  Future<void> updateBasicInfo({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    await supabase
        .from('User')
        .update({'firstName': firstName, 'lastName': lastName})
        .eq('email', email);
  }

  Future<void> updateContactInfo({
    required String email,
    required String phone,
  }) async {
    await supabase.from('User').update({'phone': phone}).eq('email', email);
  }

  Future<void> updateAddressInfo({required UserModel address}) async {
    await supabase
        .from('User')
        .update({
          'address_line1': address.addressline1,
          'address_line2': address.addressline2,
          'street': address.street,
          'city': address.city,
          'state': address.state,
          'zipCode': address.zipCode,
          'countryId': address.countryId,
        })
        .eq('id', address.id); // <-- tells Supabase to update if userId matches
  }

  Future<List<Country>> fetchCountries() async {
    final response = await supabase.from("Country").select('*');
    return (response as List)
        .map((countryJson) => Country.fromJson(countryJson))
        .toList();
  }
}
