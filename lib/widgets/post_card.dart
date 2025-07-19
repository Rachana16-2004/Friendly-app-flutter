import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  final Map post;
  const PostCard({required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  List<Map<String, dynamic>> _comments = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final data = await supabase
          .from('comments')
          .select()
          .eq('post_id', widget.post['id'])
          .order('created_at', ascending: false)
          .limit(2); // Fetch 2 latest comments

      setState(() {
        _comments = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post['image_url'] != null)
            Image.network(widget.post['image_url']),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.post['status_text'] ?? ''),
          ),
          if (_comments.isNotEmpty)
            ..._comments.map((comment) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text("- ${comment['content'] ?? ''}",
                      style: TextStyle(color: Colors.grey[700])),
                )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  Navigator.pushNamed(context, '/comments',
                      arguments: widget.post['id']);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
