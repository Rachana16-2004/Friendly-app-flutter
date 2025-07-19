import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> insertPost(Map<String, dynamic> data) async {
    await supabase.from('posts').insert(data);
  }

  Future<List<dynamic>> getPosts() async {
    return await supabase.from('posts').select().order('created_at', ascending: false);
  }
}