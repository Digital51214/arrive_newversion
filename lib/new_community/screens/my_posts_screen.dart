import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/my_post_service.dart';
import '../../new_service_screens/session_manager.dart';
import '../models/post_model.dart';
import '../theme/arrive_colors.dart';
import '../widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  final String communityType;

  const MyPostsScreen({
    super.key,
    required this.communityType,
  });

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<PostModel> _posts = [];

  int _totalPosts = 0;
  int _totalHugs = 0;
  int _totalReplies = 0;

  int _currentPage = 1;
  int _lastPage = 1;
  bool get _hasMore => _currentPage < _lastPage;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMyPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          _hasMore &&
          !_isLoadingMore) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _posts = [];
    });

    try {
      final userId = await SessionManager.getUserId();

      if (userId == 0) throw Exception('User not logged in');

      final result = await MyPostsService.getMyPosts(
        userId: userId,
        communityType: widget.communityType,
        page: 1,
      );

      if (!mounted) return;

      final stats = result['stats'] as Map<String, dynamic>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final rawPosts = result['posts'] as List<dynamic>;

      setState(() {
        _totalPosts = stats['total_posts'] ?? 0;
        _totalHugs = stats['total_hugs'] ?? 0;
        _totalReplies = stats['total_replies'] ?? 0;

        _currentPage = pagination['current_page'] ?? 1;
        _lastPage = pagination['last_page'] ?? 1;

        _posts = rawPosts.map((p) => _mapToPostModel(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final userId = await SessionManager.getUserId();

      final result = await MyPostsService.getMyPosts(
        userId: userId,
        communityType: widget.communityType,
        page: _currentPage + 1,
      );

      if (!mounted) return;

      final pagination = result['pagination'] as Map<String, dynamic>;
      final rawPosts = result['posts'] as List<dynamic>;

      setState(() {
        _currentPage = pagination['current_page'] ?? _currentPage + 1;
        _lastPage = pagination['last_page'] ?? _lastPage;
        _posts.addAll(rawPosts.map((p) => _mapToPostModel(p)).toList());
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load more: $e')),
      );
    }
  }

  PostModel _mapToPostModel(Map<String, dynamic> data) {
    final bool isAnonymous = data['is_anonymous'] == true ||
        data['is_anonymous']?.toString() == '1' ||
        data['is_anonymous']?.toString().toLowerCase() == 'true';

    return PostModel(
      id: data['id']?.toString() ?? '',
      authorName: isAnonymous
          ? 'Anonymous'
          : (data['author_name']?.toString() ?? 'You'),
      authorEmoji: isAnonymous ? '🤍' : '🌸',
      type: _mapPostType(data['post_type']?.toString() ?? '', isAnonymous),
      text: data['content']?.toString() ?? '',
      timeAgo: _formatTime(data['created_at']?.toString() ?? ''),
      hugCount: int.tryParse(data['hug_count']?.toString() ?? '0') ?? 0,
      replyCount: int.tryParse(data['reply_count']?.toString() ?? '0') ?? 0,
      isHugged: data['user_hugged'] == true ||
          data['user_hugged']?.toString() == '1' ||
          data['user_hugged']?.toString().toLowerCase() == 'true',
      isFeelThis: data['user_felt'] == true ||
          data['user_felt']?.toString() == '1' ||
          data['user_felt']?.toString().toLowerCase() == 'true',
      isSaved: data['user_saved'] == true ||
          data['user_saved']?.toString() == '1' ||
          data['user_saved']?.toString().toLowerCase() == 'true',
      isAnonymous: isAnonymous,
      isOwn: true,
    );
  }

  PostType _mapPostType(String type, bool isAnonymous) {
    if (isAnonymous) return PostType.anonymous;

    switch (type.trim().toLowerCase()) {
      case 'support':
      case 'need_support':
        return PostType.support;
      case 'win':
      case 'wins':
      case 'share_win':
        return PostType.win;
      case 'thought':
      default:
        return PostType.thought;
    }
  }

  String _formatTime(String createdAt) {
    if (createdAt.isEmpty) return '';

    try {
      final dt = DateTime.parse(createdAt.replaceAll(' ', 'T'));
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  void _onPostChanged(PostModel updated) {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == updated.id);
      if (idx != -1) _posts[idx] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ArriveColors.pink,
      onRefresh: _loadMyPosts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Posts',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.communityType == 'postpartum'
                        ? 'Your postpartum journey — only you can see this.'
                        : 'Your speak freely posts — only you can see this.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.textSoft,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!_isLoading)
                    Row(
                      children: [
                        _StatPill(num: '$_totalPosts', label: 'POSTS'),
                        const SizedBox(width: 10),
                        _StatPill(num: '$_totalHugs', label: 'HUGS RECEIVED'),
                        const SizedBox(width: 10),
                        _StatPill(num: '$_totalReplies', label: 'REPLIES'),
                      ],
                    )
                  else
                    const SizedBox(height: 54),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: ArriveColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadMyPosts,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: ArriveColors.glass,
                            border: Border.all(
                              color: ArriveColors.glassBorder,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Try Again',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: ArriveColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No posts yet.\nShare something with the community!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: ArriveColors.textSoft,
                      height: 1.7,
                    ),
                  ),
                ),
              )
            else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: PostCard(
                          post: _posts[index],
                          onChanged: _onPostChanged,
                        ),
                      ),
                      childCount: _posts.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _isLoadingMore
                        ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : !_hasMore
                        ? Center(
                      child: Text(
                        "You've seen all your posts 🌿",
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: ArriveColors.textMuted,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
        ],
      ),
    );
  }
}

// ─── Stat Pill Widget ────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String num;
  final String label;

  const _StatPill({
    required this.num,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: ArriveColors.glass,
              border: Border.all(color: ArriveColors.glassBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  num,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: ArriveColors.text,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: ArriveColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}