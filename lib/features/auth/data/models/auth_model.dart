import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.id, required super.email});

  factory AuthModel.fromSupabase(User user) {
    return AuthModel(id: user.id, email: user.email ?? '');
  }
}
