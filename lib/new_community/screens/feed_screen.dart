import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/community_all_feeds_filter_service.dart';
import '../../new_service_screens/community_feeds_filter_service.dart';
import '../../new_service_screens/community_post_reply_ service.dart';
import '../../new_service_screens/community_post_reply_screen.dart';
import '../../new_service_screens/community_post_service.dart';
import '../../new_service_screens/community_saved_post_service.dart';
import '../../new_service_screens/session_manager.dart';
import '../models/post_model.dart';
import '../theme/arrive_colors.dart';
import '../widgets/composer_card.dart';
import '../widgets/post_card.dart';
import '../widgets/post_composer_modal.dart';

// ─── Static Cache ─────────────────────────────────────────────────────────────
class FeedPostsCache {
  static final Map<String, List<PostModel>> _cache = {};
  static final Map<String, int> _pageCache = {};
  static final Map<String, bool> _hasMoreCache = {};

  static List<PostModel>? get(String key) => _cache[key];

  static int getPage(String key) => _pageCache[key] ?? 1;

  static bool hasMore(String key) => _hasMoreCache[key] ?? true;

  static void set(String key, List<PostModel> posts) {
    _cache[key] = posts;
  }

  static void setPage(String key, int page) {
    _pageCache[key] = page;
  }

  static void setHasMore(String key, bool value) {
    _hasMoreCache[key] = value;
  }

  static bool has(String key) => _cache.containsKey(key);

  static void clear(String key) {
    _cache.remove(key);
    _pageCache.remove(key);
    _hasMoreCache.remove(key);
  }

  static void clearAll() {
    _cache.clear();
    _pageCache.clear();
    _hasMoreCache.clear();
  }

  static void updatePostEverywhere(PostModel updatedPost) {
    print('========== UPDATE POST EVERYWHERE ==========');
    print('UPDATED POST ID : ${updatedPost.id}');
    print('UPDATED SAVED   : ${updatedPost.isSaved}');
    print('UPDATED HUGGED  : ${updatedPost.isHugged}');
    print('UPDATED HUGS    : ${updatedPost.hugCount}');
    print('UPDATED REPLIES : ${updatedPost.replyCount}');

    for (final entry in _cache.entries) {
      final list = List<PostModel>.from(entry.value);
      final index = list.indexWhere((post) => post.id == updatedPost.id);

      if (index != -1) {
        list[index] = updatedPost;
        _cache[entry.key] = list;

        print('UPDATED IN CACHE KEY : ${entry.key}');
      }
    }

    print('===========================================');
  }

  // ── FIX 2: duplicate check karte hue prepend karo ──
  static void prependIfAbsent(String key, PostModel post) {
    if (!_cache.containsKey(key)) return;
    final list = List<PostModel>.from(_cache[key]!);
    final alreadyExists = list.any((p) => p.id == post.id);
    if (!alreadyExists) {
      _cache[key] = [post, ...list];
    }
  }
}

// ─── Filter Labels ────────────────────────────────────────────────────────────
const List<String> _filterLabels = [
  'All',
  '💭 Thoughts',
  '🤝 Support',
  '✨ Wins',
  '🤍 Anonymous',
];

// ─── FeedScreen ───────────────────────────────────────────────────────────────
class FeedScreen extends StatefulWidget {
  final String selectedMode;

  const FeedScreen({
    super.key,
    required this.selectedMode,
  });

  bool get isSpeakFreely => selectedMode == 'speak freely mode';

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _filterIndex = 0;

  bool _isCreatingPost = false;
  bool _isAddingReply = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  String? _replyingPostId;

  final Map<String, List<ReplyModel>> _postReplies = {};
  final Set<String> _expandedReplyPostIds = {};
  final Set<String> _loadingReplyPostIds = {};

  final Set<String> _savingPostIds = {};
  final ScrollController _scrollController = ScrollController();

  String get _communityType {
    return widget.isSpeakFreely ? 'free_speak' : 'postpartum';
  }

  String get _cacheKey {
    return '${widget.selectedMode}__${_communityType}__filter_$_filterIndex';
  }

  List<PostModel> get _posts {
    return FeedPostsCache.get(_cacheKey) ?? [];
  }

  Color get _activeColor {
    return widget.isSpeakFreely ? ArriveColors.speakBlue : ArriveColors.pink;
  }

  String get _communityTitle {
    return widget.isSpeakFreely
        ? 'SPEAK FREELY COMMUNITY'
        : 'POSTPARTUM COMMUNITY';
  }

  bool get _isAllFilter => _filterIndex == 0;

  @override
  void initState() {
    super.initState();

    print('========== FEED SCREEN INIT ==========');
    print('SELECTED MODE  : ${widget.selectedMode}');
    print('COMMUNITY TYPE : $_communityType');
    print('CACHE KEY      : $_cacheKey');
    print('=====================================');

    _scrollController.addListener(_onScroll);

    if (!FeedPostsCache.has(_cacheKey)) {
      _loadPosts();
    }
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedMode != widget.selectedMode) {
      print('========== MODE CHANGED ==========');
      print('OLD MODE : ${oldWidget.selectedMode}');
      print('NEW MODE : ${widget.selectedMode}');
      print('NEW COMMUNITY TYPE : $_communityType');
      print('=================================');

      setState(() {
        _filterIndex = 0;
      });

      if (!FeedPostsCache.has(_cacheKey)) {
        _loadPosts();
      } else {
        setState(() {});
      }
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

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  Future<int> _getUserId() async {
    final user = await SessionManager.getUser();

    return int.tryParse(
      user?['id']?.toString() ?? '',
    ) ??
        0;
  }

  Future<Map<String, dynamic>> _buildAllBody({int page = 1}) async {
    final int userId = await _getUserId();

    final body = <String, dynamic>{
      'user_id': userId,
      'community_type': _communityType,
      'per_page': 12,
      'page': page,
    };

    print('========== BUILD ALL BODY ==========');
    print('USER ID        : $userId');
    print('COMMUNITY TYPE : $_communityType');
    print('PAGE           : $page');
    print('FINAL BODY     : $body');
    print('===================================');

    return body;
  }

  Future<Map<String, dynamic>> _buildFilterBody({int page = 1}) async {
    final int userId = await _getUserId();

    final body = <String, dynamic>{
      'user_id': userId,
      'community_type': _communityType,
      'per_page': 12,
      'page': page,
    };

    if (_filterIndex == 1) {
      body['post_type'] = 'thought';
    } else if (_filterIndex == 2) {
      body['post_type'] = 'need_support';
    } else if (_filterIndex == 3) {
      body['post_type'] = 'share_win';
    } else if (_filterIndex == 4) {
      body['post_type'] = 'anonymous';
    }

    print('========== BUILD FILTER BODY ==========');
    print('USER ID        : $userId');
    print('FILTER INDEX   : $_filterIndex');
    print('FILTER LABEL   : ${_filterLabels[_filterIndex]}');
    print('COMMUNITY TYPE : $_communityType');
    print('PAGE           : $page');
    print('FINAL BODY     : $body');
    print('=====================================');

    return body;
  }

  Future<Map<String, dynamic>> _fetchPostsBySelectedFilter({
    required int page,
  }) async {
    final int userId = await _getUserId();

    if (_isAllFilter) {
      final body = await _buildAllBody(page: page);

      return CommunityAllFeedsFilterService.fetchPosts(
        body: body,
      );
    }

    if (_filterIndex == 1) {
      return CommunityFilterFeedsService.fetchFilteredPosts(
        userId: userId,
        communityType: _communityType,
        postType: 'thought',
        perPage: 12,
        page: page,
      );
    }

    if (_filterIndex == 2) {
      return CommunityFilterFeedsService.fetchFilteredPosts(
        userId: userId,
        communityType: _communityType,
        postType: 'need_support',
        perPage: 12,
        page: page,
      );
    }

    if (_filterIndex == 3) {
      return CommunityFilterFeedsService.fetchFilteredPosts(
        userId: userId,
        communityType: _communityType,
        postType: 'share_win',
        perPage: 12,
        page: page,
      );
    }

    if (_filterIndex == 4) {
      return CommunityFilterFeedsService.fetchAnonymousPosts(
        userId: userId,
        communityType: _communityType,
        perPage: 12,
        page: page,
      );
    }

    final body = await _buildFilterBody(page: page);

    return CommunityFilterFeedsService.fetchFilteredPosts(
      userId: body['user_id'] as int,
      communityType: body['community_type'].toString(),
      postType: body['post_type']?.toString() ?? 'thought',
      perPage: body['per_page'] as int,
      page: body['page'] as int,
    );
  }

  Future<void> _loadPosts() async {
    if (_isRefreshing) return;

    print('---------- LOAD POSTS START ----------');
    print('CACHE KEY : $_cacheKey');
    print('FILTER    : ${_filterLabels[_filterIndex]}');

    if (mounted) {
      setState(() => _isRefreshing = true);
    }

    try {
      final result = await _fetchPostsBySelectedFilter(page: 1);

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

      print('POSTS RECEIVED : ${rawList.length}');
      print('TOTAL POSTS    : $total');
      print('CURRENT PAGE   : $currentPage');
      print('LAST PAGE      : $lastPage');

      final posts = rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapToModel)
          .toList();

      FeedPostsCache.set(_cacheKey, posts);
      FeedPostsCache.setPage(_cacheKey, currentPage);
      FeedPostsCache.setHasMore(_cacheKey, currentPage < lastPage);

      print('CACHE POSTS COUNT : ${posts.length}');
      print('HAS MORE          : ${currentPage < lastPage}');
      print('---------- LOAD POSTS END ----------');
    } catch (e) {
      print('LOAD POSTS ERROR: $e');

      if (!FeedPostsCache.has(_cacheKey)) {
        FeedPostsCache.set(_cacheKey, []);
        FeedPostsCache.setPage(_cacheKey, 1);
        FeedPostsCache.setHasMore(_cacheKey, false);
      }

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
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    if (_isRefreshing) return;
    if (!FeedPostsCache.hasMore(_cacheKey)) return;

    print('---------- LOAD MORE START ----------');
    print('CACHE KEY : $_cacheKey');

    if (mounted) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final int nextPage = FeedPostsCache.getPage(_cacheKey) + 1;

      print('NEXT PAGE : $nextPage');

      final result = await _fetchPostsBySelectedFilter(page: nextPage);

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

      print('NEW POSTS RECEIVED : ${rawList.length}');
      print('CURRENT PAGE       : $currentPage');
      print('LAST PAGE          : $lastPage');

      final newPosts = rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapToModel)
          .toList();

      final combinedPosts = <PostModel>[
        ..._posts,
        ...newPosts,
      ];

      FeedPostsCache.set(_cacheKey, combinedPosts);
      FeedPostsCache.setPage(_cacheKey, currentPage);
      FeedPostsCache.setHasMore(_cacheKey, currentPage < lastPage);

      print('TOTAL CACHED POSTS : ${combinedPosts.length}');
      print('HAS MORE           : ${currentPage < lastPage}');
      print('---------- LOAD MORE END ----------');
    } catch (e) {
      print('LOAD MORE ERROR: $e');

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

  void _onFilterChanged(int index) {
    if (_filterIndex == index) return;

    print('========== FILTER CHANGED ==========');
    print('FROM : ${_filterLabels[_filterIndex]}');
    print('TO   : ${_filterLabels[index]}');

    setState(() {
      _filterIndex = index;
    });

    FeedPostsCache.clear(_cacheKey);

    print('NEW CACHE KEY CLEARED : $_cacheKey');
    print('CALLING API AGAIN...');
    print('===================================');

    _loadPosts();
  }

  PostModel _mapToModel(Map<String, dynamic> item) {
    final String apiType =
        item['post_type']?.toString().trim().toLowerCase() ?? 'thought';

    final bool isAnon = apiType == 'anonymous' ||
        item['is_anonymous'] == true ||
        item['is_anonymous']?.toString() == '1' ||
        item['is_anonymous']?.toString().toLowerCase() == 'true';

    print('---------- MAP POST ----------');
    print('ID        : ${item['id']}');
    print('TYPE      : $apiType');
    print('ANONYMOUS : $isAnon');
    print('SAVED     : ${item['user_saved']}');
    print('HUGGED    : ${item['user_hugged']}');
    print('FELT      : ${item['user_felt']}');
    print('HUG COUNT : ${item['hug_count']}');
    print('REPLIES   : ${item['reply_count']}');
    print('AUTHOR    : ${item['author_name']}');
    print('CONTENT   : ${item['content']}');
    print('------------------------------');

    return PostModel(
      id: item['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      authorName:
      isAnon ? 'Anonymous' : item['author_name']?.toString() ?? 'User',
      authorEmoji: isAnon ? '🤍' : '🌷',
      type: _mapPostType(apiType, isAnon),
      text: item['content']?.toString() ?? '',
      timeAgo: _formatDate(item['created_at']?.toString()),
      hugCount: int.tryParse(item['hug_count']?.toString() ?? '0') ?? 0,
      replyCount: int.tryParse(item['reply_count']?.toString() ?? '0') ?? 0,
      isHugged: item['user_hugged'] == true ||
          item['user_hugged']?.toString() == '1' ||
          item['user_hugged']?.toString().toLowerCase() == 'true',
      isFeelThis: item['user_felt'] == true ||
          item['user_felt']?.toString() == '1' ||
          item['user_felt']?.toString().toLowerCase() == 'true',
      isSaved: item['user_saved'] == true ||
          item['user_saved']?.toString() == '1' ||
          item['user_saved']?.toString().toLowerCase() == 'true',
      isAnonymous: isAnon,
    );
  }

  PostType _mapPostType(String type, bool isAnon) {
    final cleanType = type.trim().toLowerCase();

    if (isAnon || cleanType == 'anonymous') {
      return PostType.anonymous;
    }

    switch (cleanType) {
      case 'need_support':
        return PostType.support;
      case 'share_win':
        return PostType.win;
      case 'thought':
      default:
        return PostType.thought;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(raw.replaceFirst(' ', 'T'));
      final diff = DateTime.now().difference(dateTime);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays < 7) return '${diff.inDays} days ago';

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      print('DATE FORMAT ERROR: $e');
      return raw;
    }
  }

  Future<void> _onPostChanged(PostModel updated) async {
    print('========== POST CHANGED ==========');
    print('POST ID       : ${updated.id}');
    print('UPDATED SAVED : ${updated.isSaved}');
    print('UPDATED HUG   : ${updated.isHugged}');
    print('HUG COUNT     : ${updated.hugCount}');
    print('REPLY COUNT   : ${updated.replyCount}');

    final list = List<PostModel>.from(_posts);
    final index = list.indexWhere((post) => post.id == updated.id);

    if (index == -1) {
      print('POST NOT FOUND IN CURRENT CACHE');
      print('================================');
      return;
    }

    final oldPost = list[index];
    final bool saveChanged = oldPost.isSaved != updated.isSaved;

    print('OLD SAVED     : ${oldPost.isSaved}');
    print('SAVE CHANGED  : $saveChanged');

    list[index] = updated;
    FeedPostsCache.set(_cacheKey, list);
    FeedPostsCache.updatePostEverywhere(updated);

    if (mounted) {
      setState(() {});
    }

    if (saveChanged && updated.isSaved == true) {
      await _savePostToApi(
        postId: updated.id,
        oldPost: oldPost,
        optimisticPost: updated,
      );
    }

    print('================================');
  }

  Future<void> _savePostToApi({
    required String postId,
    required PostModel oldPost,
    required PostModel optimisticPost,
  }) async {
    if (_savingPostIds.contains(postId)) {
      print('SAVE API SKIPPED: Post already saving. POST ID: $postId');
      return;
    }

    _savingPostIds.add(postId);

    print('========== SAVE POST START ==========');
    print('POST ID : $postId');

    try {
      final user = await SessionManager.getUser();

      final int userId = int.tryParse(
        user?['id']?.toString() ?? '',
      ) ??
          0;

      final int parsedPostId = int.tryParse(postId) ?? 0;

      print('USER ID        : $userId');
      print('PARSED POST ID : $parsedPostId');

      if (userId == 0) {
        throw Exception('User not found');
      }

      if (parsedPostId == 0) {
        throw Exception('Invalid post id');
      }

      final result = await CommunitySavePostService.savePost(
        userId: userId,
        postId: parsedPostId,
      );

      final bool success = result['success'] == true;
      final bool saved = result['saved'] == true;

      print('SAVE RESULT SUCCESS : $success');
      print('SAVE RESULT SAVED   : $saved');
      print('SAVE MESSAGE        : ${result['message']}');

      if (!success || !saved) {
        throw Exception(result['message']?.toString() ?? 'Unable to save post');
      }

      final savedPost = _copyPostWithSaved(
        optimisticPost,
        isSaved: true,
      );

      FeedPostsCache.updatePostEverywhere(savedPost);

      if (mounted) {
        setState(() {});
      }

      print('POST SAVED LOCALLY AND ICON SHOULD STAY BRIGHT');
      print('========== SAVE POST END ==========');
    } catch (e) {
      print('SAVE POST ERROR: $e');

      FeedPostsCache.updatePostEverywhere(oldPost);

      if (mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      _savingPostIds.remove(postId);
    }
  }

  PostModel _copyPostWithSaved(
      PostModel post, {
        required bool isSaved,
      }) {
    return PostModel(
      id: post.id,
      authorName: post.authorName,
      authorEmoji: post.authorEmoji,
      type: post.type,
      text: post.text,
      timeAgo: post.timeAgo,
      hugCount: post.hugCount,
      replyCount: post.replyCount,
      isHugged: post.isHugged,
      isFeelThis: post.isFeelThis,
      isSaved: isSaved,
      isAnonymous: post.isAnonymous,
      isOwn: post.isOwn,
      replies: List<ReplyModel>.from(post.replies),
    );
  }

  PostModel _copyPostWithReplyCount(
      PostModel post, {
        required int replyCount,
        List<ReplyModel>? replies,
      }) {
    return PostModel(
      id: post.id,
      authorName: post.authorName,
      authorEmoji: post.authorEmoji,
      type: post.type,
      text: post.text,
      timeAgo: post.timeAgo,
      hugCount: post.hugCount,
      replyCount: replyCount,
      isHugged: post.isHugged,
      isFeelThis: post.isFeelThis,
      isSaved: post.isSaved,
      isAnonymous: post.isAnonymous,
      isOwn: post.isOwn,
      replies: List<ReplyModel>.from(replies ?? post.replies),
    );
  }

  bool _parseReplyBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;

    final text = value?.toString().toLowerCase().trim();

    return text == '1' || text == 'true' || text == 'yes';
  }

  ReplyModel _mapReplyToModel(Map<String, dynamic> item) {
    final bool isAnon = _parseReplyBool(item['is_anonymous']);

    print('---------- MAP REPLY ----------');
    print('REPLY ID   : ${item['id']}');
    print('POST ID    : ${item['post_id']}');
    print('ANONYMOUS  : $isAnon');
    print('AUTHOR     : ${item['author_name']}');
    print('CONTENT    : ${item['content']}');
    print('CREATED AT : ${item['created_at']}');
    print('-------------------------------');

    return ReplyModel(
      authorName:
      isAnon ? 'Anonymous Mom' : item['author_name']?.toString() ?? 'User',
      authorEmoji: isAnon ? '🤍' : '🌷',
      text: item['content']?.toString() ?? '',
    );
  }

  Future<void> _toggleReplies(PostModel post) async {
    final String postId = post.id;

    print('========== TOGGLE REPLIES ==========');
    print('POST ID            : $postId');
    print('CURRENTLY EXPANDED : ${_expandedReplyPostIds.contains(postId)}');
    print('CURRENTLY LOADING  : ${_loadingReplyPostIds.contains(postId)}');

    if (_expandedReplyPostIds.contains(postId)) {
      setState(() {
        _expandedReplyPostIds.remove(postId);
      });

      print('REPLIES COLLAPSED FOR POST ID : $postId');
      print('====================================');
      return;
    }

    if (_loadingReplyPostIds.contains(postId)) {
      print('REPLIES ALREADY LOADING FOR POST ID : $postId');
      print('====================================');
      return;
    }

    setState(() {
      _expandedReplyPostIds.add(postId);
      _loadingReplyPostIds.add(postId);
    });

    try {
      final int userId = await _getUserId();
      final int parsedPostId = int.tryParse(postId) ?? 0;

      print('FETCH REPLIES USER ID : $userId');
      print('FETCH REPLIES POST ID : $parsedPostId');

      if (userId == 0) {
        throw Exception('User not found');
      }

      if (parsedPostId == 0) {
        throw Exception('Invalid post id');
      }

      final result = await AllCommunityPostRepliesService.fetchReplies(
        userId: userId,
        postId: parsedPostId,
      );

      final rawList = result['data'] as List<dynamic>? ?? [];

      final replies = rawList
          .whereType<Map<String, dynamic>>()
          .map(_mapReplyToModel)
          .toList();

      print('FINAL MAPPED REPLIES COUNT : ${replies.length}');

      _postReplies[postId] = replies;

      final updatedPost = _copyPostWithReplyCount(
        post,
        replyCount: replies.length,
        replies: replies,
      );

      FeedPostsCache.updatePostEverywhere(updatedPost);

      final currentList = List<PostModel>.from(_posts);
      final index = currentList.indexWhere((item) => item.id == postId);

      if (index != -1) {
        currentList[index] = updatedPost;
        FeedPostsCache.set(_cacheKey, currentList);
      }

      if (mounted) {
        setState(() {});
      }

      print('REPLIES LOADED AND POST COUNT UPDATED');
      print('========== TOGGLE REPLIES END ==========');
    } catch (e) {
      print('TOGGLE REPLIES ERROR: $e');

      if (mounted) {
        setState(() {
          _expandedReplyPostIds.remove(postId);
        });

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
        setState(() {
          _loadingReplyPostIds.remove(postId);
        });
      }
    }
  }

  void _openComposer() {
    PostComposerModal.show(
      context,
      onSubmit: ({
        required String content,
        required String type,
        required bool isAnonymous,
      }) async {
        final firstName = await SessionManager.getFirstName();

        await _createPost(
          content: content,
          type: type,
          isAnonymous: isAnonymous,
          authorName: isAnonymous ? 'Anonymous' : firstName,
        );
      },
    );
  }

  Future<void> _createPost({
    required String content,
    required String type,
    required bool isAnonymous,
    required String authorName,
  }) async {
    if (_isCreatingPost) return;

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    final String finalType = isAnonymous ? 'anonymous' : type.trim();

    print('---------- CREATE POST START ----------');
    print('CONTENT        : $content');
    print('TYPE FROM UI   : $type');
    print('FINAL TYPE     : $finalType');
    print('ANONYMOUS      : $isAnonymous');
    print('AUTHOR         : $authorName');

    setState(() => _isCreatingPost = true);

    try {
      final user = await SessionManager.getUser();

      final int userId = int.tryParse(
        user?['id']?.toString() ?? '',
      ) ??
          0;

      if (userId == 0) {
        throw Exception('User not found');
      }

      final result = await CommunityPostService.createPost(
        userId: userId,
        content: content,
        type: finalType,
        isAnonymous: isAnonymous,
        mode: widget.selectedMode,
      );

      print('CREATE POST RESULT: $result');

      if (!mounted) return;

      final data = result['data'] as Map<String, dynamic>? ?? {};

      final String apiType =
          data['post_type']?.toString().trim().toLowerCase() ?? finalType;

      final bool postIsAnonymous = isAnonymous ||
          apiType == 'anonymous' ||
          data['is_anonymous'] == true ||
          data['is_anonymous']?.toString() == '1' ||
          data['is_anonymous']?.toString().toLowerCase() == 'true';

      final newPost = PostModel(
        id: data['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: postIsAnonymous
            ? 'Anonymous'
            : data['author_name']?.toString() ?? authorName,
        authorEmoji: postIsAnonymous ? '🤍' : '🌿',
        type: _mapPostType(apiType, postIsAnonymous),
        text: data['content']?.toString() ?? content,
        timeAgo: 'Just now',
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
        isAnonymous: postIsAnonymous,
      );

      // ── FIX 2: prependIfAbsent use karo — duplicate kabhi nahi hoga ──
      final String allKey =
          '${widget.selectedMode}__${_communityType}__filter_0';
      final String thoughtsKey =
          '${widget.selectedMode}__${_communityType}__filter_1';
      final String supportKey =
          '${widget.selectedMode}__${_communityType}__filter_2';
      final String winsKey =
          '${widget.selectedMode}__${_communityType}__filter_3';
      final String anonymousKey =
          '${widget.selectedMode}__${_communityType}__filter_4';

      // Har relevant cache mein safely prepend karo
      FeedPostsCache.prependIfAbsent(allKey, newPost);

      if (postIsAnonymous || newPost.type == PostType.anonymous) {
        FeedPostsCache.prependIfAbsent(anonymousKey, newPost);
      } else if (newPost.type == PostType.thought) {
        FeedPostsCache.prependIfAbsent(thoughtsKey, newPost);
      } else if (newPost.type == PostType.support) {
        FeedPostsCache.prependIfAbsent(supportKey, newPost);
      } else if (newPost.type == PostType.win) {
        FeedPostsCache.prependIfAbsent(winsKey, newPost);
      }

      // Agar current cache key alag hai (koi specific filter active),
      // tab bhi us mein insert karo — but sirf agar post us filter se match kare
      if (_cacheKey != allKey &&
          _matchesCurrentFilter(newPost.type, postIsAnonymous)) {
        FeedPostsCache.prependIfAbsent(_cacheKey, newPost);
      }

      setState(() {});

      print('POST CREATED AND ADDED TO CORRECT FILTER CACHE');
      print('POST TYPE       : ${newPost.type}');
      print('POST ANONYMOUS  : ${newPost.isAnonymous}');
      print('ALL KEY         : $allKey');
      print('ANONYMOUS KEY   : $anonymousKey');
      print('---------- CREATE POST END ----------');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Post shared!'),
        ),
      );
    } catch (e) {
      print('CREATE POST ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingPost = false);
      }
    }
  }

  bool _matchesCurrentFilter(PostType type, bool isAnon) {
    switch (_filterIndex) {
      case 1:
        return type == PostType.thought;
      case 2:
        return type == PostType.support;
      case 3:
        return type == PostType.win;
      case 4:
        return isAnon || type == PostType.anonymous;
      default:
        return true;
    }
  }

  void _openReplySheet(PostModel post) {
    final TextEditingController replyController = TextEditingController();

    bool isAnonymous = false;
    bool isSubmitting = false;

    print('========== OPEN REPLY SHEET ==========');
    print('POST ID : ${post.id}');
    print('=====================================');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submitReply() async {
              if (isSubmitting) {
                print('REPLY SUBMIT SKIPPED: Already submitting');
                return;
              }

              final text = replyController.text.trim();

              print('========== REPLY SUBMIT TAPPED ==========');
              print('POST ID      : ${post.id}');
              print('REPLY TEXT   : $text');
              print('IS ANONYMOUS : $isAnonymous');
              print('========================================');

              if (text.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Please write a reply first'),
                  ),
                );
                return;
              }

              setSheetState(() {
                isSubmitting = true;
              });

              try {
                await _addReplyToPost(
                  post: post,
                  content: text,
                  isAnonymous: isAnonymous,
                );

                await Future.delayed(const Duration(milliseconds: 120));

                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }
              } catch (e) {
                print('BOTTOM SHEET SUBMIT ERROR: $e');

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                    ),
                  );
                }
              } finally {
                try {
                  setSheetState(() {
                    isSubmitting = false;
                  });
                } catch (e) {
                  print('SHEET SET STATE AFTER CLOSE SKIPPED: $e');
                }
              }
            }

            // ── FIX 1 (reply sheet): same keyboard fix ──
            final double bottomInset =
                MediaQuery.of(sheetContext).viewInsets.bottom;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  bottom: bottomInset + 14,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 22,
                      sigmaY: 22,
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2422).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _activeColor.withOpacity(0.22),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.38),
                            blurRadius: 32,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: AbsorbPointer(
                        absorbing: isSubmitting,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: isSubmitting ? 0.72 : 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 44,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: _activeColor.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          _activeColor.withOpacity(0.35),
                                          _activeColor.withOpacity(0.08),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: _activeColor.withOpacity(0.35),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '💬',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add a reply',
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w400,
                                            color: ArriveColors.text,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Write something gentle, honest, or supportive.',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w300,
                                            color: ArriveColors.textMuted,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isSubmitting
                                        ? null
                                        : () {
                                      print('REPLY SHEET CLOSE TAPPED');

                                      if (Navigator.of(sheetContext)
                                          .canPop()) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ArriveColors.glassBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: ArriveColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: ArriveColors.glassBorder,
                                  ),
                                ),
                                child: Text(
                                  post.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    height: 1.55,
                                    color: ArriveColors.textSoft,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ArriveColors.glassBorder,
                                  ),
                                ),
                                child: TextField(
                                  controller: replyController,
                                  minLines: 4,
                                  maxLines: 7,
                                  cursorColor: _activeColor,
                                  textInputAction: TextInputAction.newline,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.5,
                                    color: ArriveColors.text,
                                    height: 1.5,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type your reply here...',
                                    hintStyle: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: ArriveColors.textMuted,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: isSubmitting
                                    ? null
                                    : () {
                                  setSheetState(() {
                                    isAnonymous = !isAnonymous;
                                  });

                                  print(
                                    'REPLY ANONYMOUS CHANGED : $isAnonymous',
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAnonymous
                                        ? _activeColor.withOpacity(0.12)
                                        : Colors.black.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isAnonymous
                                          ? _activeColor.withOpacity(0.5)
                                          : ArriveColors.glassBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isAnonymous
                                              ? _activeColor.withOpacity(0.9)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isAnonymous
                                                ? _activeColor
                                                : ArriveColors.textMuted
                                                .withOpacity(0.45),
                                          ),
                                        ),
                                        child: isAnonymous
                                            ? const Icon(
                                          Icons.check_rounded,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Reply anonymously',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: ArriveColors.text,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Your name will stay hidden on this reply.',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w300,
                                                color: ArriveColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        isAnonymous ? '🤍' : '🌷',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: isSubmitting
                                          ? null
                                          : () {
                                        print('REPLY CANCEL TAPPED');

                                        if (Navigator.of(sheetContext)
                                            .canPop()) {
                                          Navigator.of(sheetContext).pop();
                                        }
                                      },
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.16),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: ArriveColors.glassBorder,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: ArriveColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: isSubmitting ? null : submitReply,
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              _activeColor.withOpacity(0.95),
                                              _activeColor.withOpacity(0.68),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: _activeColor.withOpacity(0.65),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              _activeColor.withOpacity(0.22),
                                              blurRadius: 18,
                                              offset: const Offset(0, 7),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: isSubmitting
                                              ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(
                                                width: 17,
                                                height: 17,
                                                child:
                                                CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Sending...',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13.5,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                              : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.send_rounded,
                                                size: 17,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 7),
                                              Text(
                                                'Send Reply',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 13.5,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          replyController.dispose();
          print('REPLY CONTROLLER DISPOSED SAFELY');
        } catch (e) {
          print('REPLY CONTROLLER DISPOSE ERROR SKIPPED: $e');
        }
      });

      print('REPLY SHEET CLOSED');
    });
  }

  Future<void> _addReplyToPost({
    required PostModel post,
    required String content,
    required bool isAnonymous,
  }) async {
    if (_isAddingReply) {
      print('ADD REPLY SKIPPED: Already adding reply');
      return;
    }

    final String trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply first')),
      );
      return;
    }

    print('========== ADD REPLY START ==========');
    print('POST ID      : ${post.id}');
    print('CONTENT      : $trimmedContent');
    print('IS ANONYMOUS : $isAnonymous');

    if (mounted) {
      setState(() {
        _isAddingReply = true;
        _replyingPostId = post.id;
      });
    }

    try {
      final user = await SessionManager.getUser();

      final int userId = int.tryParse(
        user?['id']?.toString() ?? '',
      ) ??
          0;

      final int parsedPostId = int.tryParse(post.id) ?? 0;

      print('USER ID        : $userId');
      print('PARSED POST ID : $parsedPostId');

      if (userId == 0) {
        throw Exception('User not found');
      }

      if (parsedPostId == 0) {
        throw Exception('Invalid post id');
      }

      final result = await CommunityPostReplyService.createReply(
        userId: userId,
        postId: parsedPostId,
        content: trimmedContent,
        isAnonymous: isAnonymous,
      );

      print('ADD REPLY RESULT : $result');

      final data = result['data'] as Map<String, dynamic>? ?? {};

      final bool replyIsAnonymous = _parseReplyBool(data['is_anonymous']);

      final newReply = ReplyModel(
        authorName: replyIsAnonymous
            ? 'Anonymous Mom'
            : data['author_name']?.toString() ?? 'You',
        authorEmoji: replyIsAnonymous ? '🤍' : '🌷',
        text: data['content']?.toString() ?? trimmedContent,
      );

      final existingReplies = List<ReplyModel>.from(
        _postReplies[post.id] ?? [],
      );

      existingReplies.add(newReply);

      _postReplies[post.id] = existingReplies;
      _expandedReplyPostIds.add(post.id);

      final updatedPost = _copyPostWithReplyCount(
        post,
        replyCount: existingReplies.length,
        replies: existingReplies,
      );

      FeedPostsCache.updatePostEverywhere(updatedPost);

      final currentList = List<PostModel>.from(_posts);
      final index = currentList.indexWhere((item) => item.id == post.id);

      if (index != -1) {
        currentList[index] = updatedPost;
        FeedPostsCache.set(_cacheKey, currentList);
      }

      if (mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Reply added successfully.',
            ),
          ),
        );
      }

      print('REPLY ID      : ${data['id']}');
      print('AUTHOR NAME   : ${data['author_name']}');
      print('CREATED AT    : ${data['created_at']}');
      print('UPDATED COUNT : ${updatedPost.replyCount}');
      print('========== ADD REPLY END ==========');
    } catch (e) {
      print('ADD REPLY ERROR: $e');

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
        setState(() {
          _isAddingReply = false;
          _replyingPostId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          color: _activeColor,
          onRefresh: _loadPosts,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 1,
                                color: _activeColor.withOpacity(0.35),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _communityTitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: _activeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "You're not alone.",
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: ArriveColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isSpeakFreely
                                ? 'Speak freely, share safely, and be heard.'
                                : 'Share, get support, save what helps. No profiles, no pressure.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: ArriveColors.textSoft,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    ComposerCard(
                      onTap: _isCreatingPost ? () {} : _openComposer,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filterLabels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (_, index) {
                          final bool active = index == _filterIndex;

                          return GestureDetector(
                            onTap: () => _onFilterChanged(index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 8,
                                  sigmaY: 8,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? _activeColor.withOpacity(0.15)
                                        : ArriveColors.glass,
                                    border: Border.all(
                                      color: active
                                          ? _activeColor.withOpacity(0.5)
                                          : ArriveColors.glassBorder,
                                      width: active ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _filterLabels[index],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: active
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: active
                                          ? _activeColor
                                          : ArriveColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              if (_isRefreshing && _posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _activeColor),
                        const SizedBox(height: 14),
                        Text(
                          'Loading ${_filterLabels[_filterIndex]} posts...',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: ArriveColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!_isRefreshing && _posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🌿',
                          style: TextStyle(fontSize: 36),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No posts here yet.',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: ArriveColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Be the first to share something.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: ArriveColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                  if (_isRefreshing)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Center(
                          child: SizedBox(
                            height: 2,
                            child: LinearProgressIndicator(
                              color: _activeColor,
                              backgroundColor: _activeColor.withOpacity(0.15),
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
                          final post = _posts[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: PostCard(
                              post: post,
                              onChanged: _onPostChanged,
                              onReplyTap: () => _openReplySheet(post),
                              onRepliesToggle: () => _toggleReplies(post),
                              apiReplies: _postReplies[post.id] ?? const [],
                              isRepliesExpanded:
                              _expandedReplyPostIds.contains(post.id),
                              isRepliesLoading:
                              _loadingReplyPostIds.contains(post.id),
                            ),
                          );
                        },
                        childCount: _posts.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _isLoadingMore
                          ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: _activeColor,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loading more...',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: ArriveColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                          : !FeedPostsCache.hasMore(_cacheKey)
                          ? Center(
                        child: Text(
                          '— You\'re all caught up —',
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
        ),
        if (_isCreatingPost)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _activeColor),
                    const SizedBox(height: 14),
                    Text(
                      'Sharing your post...',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_isAddingReply)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: _activeColor),
                    const SizedBox(height: 14),
                    Text(
                      'Adding your reply....',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
