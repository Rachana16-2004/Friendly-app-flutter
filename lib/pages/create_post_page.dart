import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import 'feed_page.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  late AnimationController _animationController;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
        _imageName = pickedFile.name;
      });

      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        if (kIsWeb) _webImageBytes = bytes;
      });
    }
  }

  Future<void> _uploadImageAndCreatePost() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (_imageBytes != null && _imageName != null) {
      final fileExt = path.extension(_imageName!);
      final fileName = "${const Uuid().v4()}$fileExt";
      final filePath = "posts/$fileName";

      await supabase.storage.from('post-images').uploadBinary(filePath, _imageBytes!);
      final publicUrl = supabase.storage.from('post-images').getPublicUrl(filePath);

      setState(() {
        _uploadedImageUrl = publicUrl;
      });

      await supabase.from('posts').insert({
        'user_id': user!.id,
        'status_text': _contentController.text,
        'image_url': _uploadedImageUrl,
      });

      setState(() => _showSuccess = true);
      _animationController.forward();

      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FeedPage(
            post: {
              'status_text': _contentController.text,
              'image_url': _uploadedImageUrl,
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final avatarUrl = user?.userMetadata?['avatar_url'] ?? '';
    final email = user?.email ?? 'Anonymous';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/friend.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          email,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'What\'s on your mind?',
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_pickedImage != null)
                            kIsWeb
                                ? _webImageBytes != null
                                    ? Image.memory(_webImageBytes!, height: 200)
                                    : const SizedBox()
                                : Image.file(
                                    File(_pickedImage!.path),
                                    height: 200,
                                  ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.image),
                                label: Text("Upload Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black87,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _uploadImageAndCreatePost,
                                icon: Icon(Icons.send),
                                label: Text("Post"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FeedPage()),
                          );
                        },
                        icon: Icon(Icons.arrow_forward),
                        label: Text("Next Page"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
