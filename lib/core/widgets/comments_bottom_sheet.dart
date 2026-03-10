import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../models/comment_model.dart';
import '../theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String collection;
  final String documentId;

  const CommentsBottomSheet({
    Key? key,
    required this.collection,
    required this.documentId,
  }) : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final name = (user.displayName == null || user.displayName!.isEmpty) ? 'Anonymous' : user.displayName!;

    final comment = CommentModel(
      id: '',
      text: text,
      authorId: user.uid,
      authorName: name,
      likedBy: [],
      createdAt: DateTime.now(),
    );

    // Clear the input and hide keyboard instantly for better UX
    _commentController.clear();
    FocusScope.of(context).unfocus();

    await _dbService.addComment(widget.collection, widget.documentId, comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Comments',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter'),
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // Comments Stream List
          Flexible(
            child: StreamBuilder<List<CommentModel>>(
              stream: _dbService.getCommentsStream(widget.collection, widget.documentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final comments = snapshot.data ?? [];
                
                if (comments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No comments yet. Be the first!',
                        style: TextStyle(color: Colors.white54, fontFamily: 'Inter')),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shrinkWrap: true,
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isLiked = user != null && comment.isLikedBy(user.uid);
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            comment.authorName[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.authorName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        fontFamily: 'Inter'),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeago.format(comment.createdAt),
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.text,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  if (user != null) {
                                    _dbService.toggleCommentLike(
                                        widget.collection, widget.documentId, comment.id, user.uid, !isLiked);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isLiked ? AppColors.primary : Colors.white54,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${comment.likedBy.length}',
                                      style: TextStyle(
                                          color: isLiked ? AppColors.primary : Colors.white54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          _commentController.text += emoji.emoji;
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.primary, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _postComment,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
