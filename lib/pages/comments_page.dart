import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final String postId;

  CommentsPage({required this.postId});

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await Supabase.instance.client
        .from('comments')
        .select('id, comment_text, created_at, user_id, profiles(username)')
        .eq('post_id', widget.postId)
        .order('created_at', ascending: false);

    setState(() {
      comments = response;
    });
  }

  Future<void> addComment() async {
    final text = _commentController.text.trim();
    final user = Supabase.instance.client.auth.currentUser;

    if (text.isEmpty || user == null) return;

    await Supabase.instance.client.from('comments').insert({
      'post_id': widget.postId,
      'comment_text': text,
      'user_id': user.id,
    });

    _commentController.clear();
    await fetchComments();
  }

 @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar with back button
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            Divider(),

            // Comments list
            Expanded(
              child: comments.isEmpty
                  ? Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final username =
                            comment['profiles']?['username'] ?? 'User';
                        final createdAt = DateTime.tryParse(
                                comment['created_at'] ?? '') ??
                            DateTime.now();
                        final relativeTime = timeago.format(createdAt);

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 20, color: Colors.deepPurple),
                                  SizedBox(width: 6),
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.deepPurple[700],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    relativeTime,
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  )
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                comment['comment_text'] ?? '',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 12),

            // Input and send button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Material(
                  color: Colors.deepPurple,
                  shape: CircleBorder(),
                  child: InkWell(
                    customBorder: CircleBorder(),
                    onTap: addComment,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}