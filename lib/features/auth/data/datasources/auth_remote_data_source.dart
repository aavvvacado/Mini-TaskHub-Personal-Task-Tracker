import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> signup(String email, String password);
  Future<void> logout();
  Future<AuthModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(email: email, password: password);
      if (response.user == null) throw const ServerFailure('Login failed: User is null');
      return AuthModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthModel> signup(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(email: email, password: password);
      // Note: If email confirmation is enabled, user might be null or session might be null.
      if (response.user == null) throw const ServerFailure('Signup failed: User is null');
      if (response.session == null) {
        throw const ServerFailure('Please check your email to verify your account.');
      }
      return AuthModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      return AuthModel.fromSupabase(user);
    }
    return null;
  }
}
