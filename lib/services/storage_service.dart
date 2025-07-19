import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadImage(Uint8List bytes, String path) async {
    await supabase.storage.from('post-images').uploadBinary(path, bytes);
    return supabase.storage.from('post-images').getPublicUrl(path);
  }
}