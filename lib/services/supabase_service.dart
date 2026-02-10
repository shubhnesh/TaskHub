import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Auth Methods
  Future<AuthResponse> signUp(String email, String password) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user != null) {
      await client.from('users').insert({
        'user_id': user.id,
        'email': user.email,
      });
    }

    return res;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  // Task Methods
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('notes')
        .select()
        .eq('uid', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addTask(String title) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('notes').insert({
      'body': title,
      'is_completed': false,
      'uid': userId,
    });
  }

  Future<void> updateTaskStatus(int id, bool isCompleted) async {
    await client
        .from('notes')
        .update({'is_completed': isCompleted}).eq('id', id);
  }

  Future<void> updateTask(int id, String newTitle) async {
    await client.from('notes').update({'body': newTitle}).eq('id', id);
  }

  Future<void> deleteTask(int id) async {
    await client.from('notes').delete().eq('id', id);
  }
}
