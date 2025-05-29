import 'package:odifarm/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  //sign in
  Future<AuthResponse> signin(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  //sign up
  Future<AuthResponse> signup(String email, String password) async {
    final authUser = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (authUser.user != null && authUser.session?.user != null) {
      await UserService().createUser(email, authUser.session!.user.id);
    }
    return authUser;
  }

  //sign out
  Future<void> signout() async {
    return await supabase.auth.signOut();
  }

  Future<String> fetchUserByemail() async {
    final user = supabase.auth.currentUser;
    final email = user?.email;
    if (email == null) {
      throw Exception('No user is currently signed in or email is null');
    }
    return email;
  }
}
