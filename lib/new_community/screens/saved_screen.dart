import 'dart:ui';

import 'package:arrive_newversion/new_service_screens/community_list_saved_feeds_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/session_manager.dart';
import '../models/post_model.dart';
import '../theme/arrive_colors.dart';
import '../widgets/post_card.dart';

// ─── Saved Posts Cache ────────────────────────────────────────────────────────
class SavedPostsCache {
  static List<PostModel>? _posts;
  static int _currentPage = 1;
  static int _lastPage = 1;

  static bool get hasData => _posts != null;

  static List<PostModel> get posts => _posts ?? [];

  static int get currentPage => _currentPage;

  static int get lastPage => _lastPage;

  static bool get hasMore => _currentPage < _lastPage;

  static void set({
    required List<PostModel> posts,
    required int currentPage,
    required int lastPage,
  }) {
    _posts = posts;
    _currentPage = currentPage;
    _lastPage = lastPage;
  }

  static void append({
    required List<PostModel> posts,
    required int currentPage,
    required int lastPage,
  }) {
    _posts = [
      ...(_posts ?? []),
      ...posts,
    ];
    _currentPage = currentPage;
    _lastPage = lastPage;
  }

  static void clear() {
    _posts = null;
    _currentPage = 1;
    _lastPage = 1;
  }

  static void update(PostModel updated) {
    if (_posts == null) return;

    final index = _posts!.indexWhere((post) => post.id == updated.id);

    if (index != -1) {
      _posts![index] = updated;
    }
  }

  static void remove(String id) {
    _posts?.removeWhere((post) => post.id == id);
  }
}

// ─── SavedScreen ──────────────────────────────────────────────────────────────
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  List<PostModel> get _posts => SavedPostsCache.posts;

  bool get _hasMore => SavedPostsCache.hasMore;

  @override
  void initState() {
    super.initState();

    print('========== SAVED SCREEN INIT ==========');

    _scrollController.addListener(_onScroll);

    if (SavedPostsCache.hasData) {
      _isLoading = false;
    } else {
      _loadSavedPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isLoading || _isRefreshing || _isLoadingMore) return;
    if (!_hasMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadMorePosts();
    }
  }

  Future<int> _getUserId() async {
    final user = await SessionManager.getUser();

    return int.tryParse(
      user?['id']?.toString() ?? '',
    ) ??
        0;
  }

  Future<void> _loadSavedPosts() async {
    if (_isRefreshing) return;

    print('---------- LOAD SAVED POSTS START ----------');

    if (mounted) {
      setState(() {
        _isLoading = true;
        _isRefreshing = true;
        _errorMessage = null;
      });
    }

    try {
      final int userId = await _getUserId();

      print('USER ID : $userId');

      if (userId == 0) {
        throw Exception('User not found');
      }

      final result = await CommunityListSavedFeedsService.fetchSavedPosts(
        userId: userId,
        perPage: 10,
        page: 1,
      );

      final paginationData = result['data'] as Map<String, dynamic>? ?? {};
      final rawList = paginationData['data'] as List<dynamic>? ?? [];

      final int currentPage = int.tryParse(
        paginationData['current_page']?.toString() ?? '1',
      ) ??
          1;

      final int lastPage = int.tryParse(
        paginationData['last_page']?.toString() ?? '1',
      ) ??
          1;

      final int total = int.tryParse(
        paginationData['total']?.toString() ?? '0',
      ) ??
          0;

      print('SAVED POSTS RECEIVED : ${rawList.length}');
      print('TOTAL SAVED POSTS    : $total');
      print('CURRENT PAGE         : $currentPage');
      print('LAST PAGE            : $lastPage');

      final posts = rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapToPostModel)
          .toList();

      SavedPostsCache.set(
        posts: posts,
        currentPage: currentPage,
        lastPage: lastPage,
      );

      print('CACHE SAVED POSTS COUNT : ${SavedPostsCache.posts.length}');
      print('---------- LOAD SAVED POSTS END ----------');
    } catch (e) {
      print('LOAD SAVED POSTS ERROR: $e');

      SavedPostsCache.clear();

      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    if (!_hasMore) return;

    print('---------- LOAD MORE SAVED POSTS START ----------');

    if (mounted) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final int userId = await _getUserId();

      if (userId == 0) {
        throw Exception('User not found');
      }

      final int nextPage = SavedPostsCache.currentPage + 1;

      print('NEXT PAGE : $nextPage');

      final result = await CommunityListSavedFeedsService.fetchSavedPosts(
        userId: userId,
        perPage: 10,
        page: nextPage,
      );

      final paginationData = result['data'] as Map<String, dynamic>? ?? {};
      final rawList = paginationData['data'] as List<dynamic>? ?? [];

      final int currentPage = int.tryParse(
        paginationData['current_page']?.toString() ?? '$nextPage',
      ) ??
          nextPage;

      final int lastPage = int.tryParse(
        paginationData['last_page']?.toString() ?? '$currentPage',
      ) ??
          currentPage;

      print('MORE SAVED POSTS RECEIVED : ${rawList.length}');
      print('CURRENT PAGE              : $currentPage');
      print('LAST PAGE                 : $lastPage');

      final newPosts = rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapToPostModel)
          .toList();

      SavedPostsCache.append(
        posts: newPosts,
        currentPage: currentPage,
        lastPage: lastPage,
      );

      print('TOTAL CACHED SAVED POSTS : ${SavedPostsCache.posts.length}');
      print('---------- LOAD MORE SAVED POSTS END ----------');
    } catch (e) {
      print('LOAD MORE SAVED POSTS ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  PostModel _mapToPostModel(Map<String, dynamic> data) {
    final bool isAnon = data['is_anonymous'] == true ||
        data['is_anonymous']?.toString() == '1';

    final String apiType = data['post_type']?.toString() ?? 'thought';

    print('---------- MAP SAVED POST ----------');
    print('ID          : ${data['id']}');
    print('TYPE        : $apiType');
    print('ANONYMOUS   : $isAnon');
    print('SAVED       : ${data['user_saved']}');
    print('SAVED AT    : ${data['saved_at']}');
    print('POST DATE   : ${data['post_created_at']}');
    print('AUTHOR      : ${data['author_name']}');
    print('CONTENT     : ${data['content']}');
    print('EMOJI       : ${data['emoji']}');
    print('-----------------------------------');

    // ── API se emoji lo, warna fallback ──
    final String authorEmoji = isAnon
        ? '🤍'
        : (data['emoji']?.toString().trim().isNotEmpty == true
        ? data['emoji'].toString().trim()
        : '🌷');

    return PostModel(
      id: data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: isAnon
          ? 'Anonymous'
          : data['author_name']?.toString() ?? 'User',
      authorEmoji: authorEmoji,
      type: _mapPostType(apiType, isAnon),
      text: data['content']?.toString() ?? '',
      timeAgo: _formatTime(
        data['saved_at']?.toString() ??
            data['post_created_at']?.toString() ??
            '',
      ),
      hugCount: int.tryParse(data['hug_count']?.toString() ?? '0') ?? 0,
      replyCount: int.tryParse(data['reply_count']?.toString() ?? '0') ?? 0,
      isHugged: data['user_hugged'] == true ||
          data['user_hugged']?.toString() == '1',
      isFeelThis: data['user_felt'] == true ||
          data['user_felt']?.toString() == '1',
      isSaved: data['user_saved'] == true ||
          data['user_saved']?.toString() == '1',
      isAnonymous: isAnon,
    );
  }

  PostType _mapPostType(String type, bool isAnon) {
    if (isAnon) {
      return PostType.anonymous;
    }

    switch (type.trim().toLowerCase()) {
      case 'need_support':
        return PostType.support;
      case 'share_win':
        return PostType.win;
      case 'thought':
      default:
        return PostType.thought;
    }
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(raw.replaceFirst(' ', 'T'));
      final diff = DateTime.now().difference(dateTime);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      print('SAVED DATE FORMAT ERROR: $e');
      return raw;
    }
  }

  void _onPostChanged(PostModel updated) {
    print('========== SAVED POST CHANGED ==========');
    print('POST ID  : ${updated.id}');
    print('IS SAVED : ${updated.isSaved}');

    if (!updated.isSaved) {
      SavedPostsCache.remove(updated.id);
      print('POST REMOVED FROM SAVED LIST');
    } else {
      SavedPostsCache.update(updated);
      print('POST UPDATED IN SAVED LIST');
    }

    if (mounted) {
      setState(() {});
    }

    print('=======================================');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ArriveColors.pink,
      onRefresh: _loadSavedPosts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Posts',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posts from other moms that meant something to you. Only you can see these.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: ArriveColors.textSoft,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Hint Banner ───
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ArriveColors.gold.withOpacity(0.07),
                border: Border.all(
                  color: ArriveColors.gold.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '🔖 Tap the bookmark on any post to save it here for whenever you need it.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: ArriveColors.gold.withOpacity(0.8),
                  height: 1.55,
                ),
              ),
            ),
          ),

          // ─── Loading ───
          if (_isLoading && _posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: ArriveColors.pink,
                ),
              ),
            )

          // ─── Error ───
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⚠️',
                        style: TextStyle(fontSize: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: ArriveColors.textSoft,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadSavedPosts,
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

          // ─── Empty ───
          else if (_posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔖',
                        style: TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nothing saved yet.',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: ArriveColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bookmark posts that resonate with you.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: ArriveColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // ─── Posts List ───
            else ...[
                if (_isRefreshing)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            color: ArriveColors.pink,
                            backgroundColor: ArriveColors.pink.withOpacity(0.15),
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: PostCard(
                            post: _posts[index],
                            onChanged: _onPostChanged,
                          ),
                        );
                      },
                      childCount: _posts.length,
                    ),
                  ),
                ),

                // ─── Footer Loader / End Text ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _isLoadingMore
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: ArriveColors.pink,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loading more saved posts...',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: ArriveColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                        : !_hasMore && _posts.isNotEmpty
                        ? Center(
                      child: Text(
                        '— All saved posts loaded —',
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