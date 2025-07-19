import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_post_page.dart';
import 'comments_page.dart';

class FeedPage extends StatefulWidget {
  final Map<String, dynamic>? post;

  FeedPage({this.post});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      posts.insert(0, widget.post!);
    }
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await Supabase.instance.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      posts = response;
    });
  }

  Future<void> handleLike(int index) async {
    final post = posts[index];
    final String postId = post['id'];
    await Supabase.instance.client
        .from('posts')
        .update({'likes': (post['likes'] ?? 0) + 1})
        .eq('id', postId);
    setState(() {
      posts[index]['likes'] = (post['likes'] ?? 0) + 1;
    });
  }

  void handleComment(int index) {
    final String postId = posts[index]['id'];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommentsPage(postId: postId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        title: Text("Friends Feed"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePostPage()),
              );
              if (result == true) fetchPosts();
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onLongPress: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPostPage(post: post),
                  ),
                );
                if (result == true) fetchPosts();
              },
              child: Card(
                margin: EdgeInsets.all(12),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(4, 4),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (post['image_url'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            alignment: Alignment.center,
                            child: Image.network(
                              post['image_url'],
                              height: 250,
                              width: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 250,
                                width: 250,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 250,
                                  width: 250,
                                  child:
                                      Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                        ),
                      if ((post['status_text'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 10),
                          child: Text(
                            post['status_text'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        color: Color(0xFFF8F5FC),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => handleLike(index),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(Icons.thumb_up_alt_outlined, size: 18),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text((post['likes'] ?? 0).toString()),
                            SizedBox(width: 20),
                            InkWell(
                              onTap: () => handleComment(index),
                              child: Icon(Icons.comment_outlined),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class EditPostPage extends StatefulWidget {
  final Map post;
  EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _controller;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post['status_text']);
  }

  Future<void> updatePost() async {
    setState(() => _isUpdating = true);

    final supabase = Supabase.instance.client;
    final postId = widget.post['id'];

    final response = await supabase.from('posts').update({
      'status_text': _controller.text,
    }).eq('id', postId);

    setState(() => _isUpdating = false);

    if (response.error != null) {
      print("❌ Update failed: ${response.error!.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update post")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Post updated")),
    );

    Navigator.pop(context, true);
  }

  Future<void> deletePost() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('posts')
          .delete()
          .eq('id', widget.post['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Post deleted")),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: deletePost,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: "Update caption",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : updatePost,
                icon: Icon(Icons.save),
                label: _isUpdating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Update Post", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
