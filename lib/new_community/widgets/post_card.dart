import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../new_service_screens/community_react_service.dart';
import '../../new_service_screens/session_manager.dart';
import '../models/post_model.dart';
import '../theme/arrive_colors.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final ValueChanged<PostModel> onChanged;
  final VoidCallback? onReplyTap;

  final VoidCallback? onRepliesToggle;
  final List<ReplyModel> apiReplies;
  final bool isRepliesExpanded;
  final bool isRepliesLoading;

  const PostCard({
    super.key,
    required this.post,
    required this.onChanged,
    this.onReplyTap,
    this.onRepliesToggle,
    this.apiReplies = const [],
    this.isRepliesExpanded = false,
    this.isRepliesLoading = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late PostModel _post;
  final TextEditingController _replyController = TextEditingController();

  bool _showReplyBox = false;
  bool _showEmojiPicker = false;
  bool _isReactingHug = false;
  bool _isReactingFeel = false;

  int _feelCount = 0;

  final List<String> _emojis = [
    '😊',
    '🥹',
    '💙',
    '🩵',
    '🤍',
    '🌸',
    '✨',
    '🫶',
    '🤗',
    '😭',
    '😌',
    '🌿',
    '💭',
    '🕊️',
    '🙏',
    '🥰',
    '💪',
    '🌷',
  ];

  @override
  void initState() {
    super.initState();
    _post = widget.post;

    print('========== POST CARD INIT ==========');
    print('POST ID       : ${_post.id}');
    print('REPLY COUNT   : ${_post.replyCount}');
    print('API REPLIES   : ${widget.apiReplies.length}');
    print('EXPANDED      : ${widget.isRepliesExpanded}');
    print('===================================');

    _feelCount = 0;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    _post = widget.post;

    print('========== POST CARD UPDATED ==========');
    print('POST ID       : ${_post.id}');
    print('REPLY COUNT   : ${_post.replyCount}');
    print('API REPLIES   : ${widget.apiReplies.length}');
    print('EXPANDED      : ${widget.isRepliesExpanded}');
    print('LOADING       : ${widget.isRepliesLoading}');
    print('=====================================');
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  PostModel _copy({
    bool? isHugged,
    int? hugCount,
    bool? isFeelThis,
    bool? isSaved,
    int? replyCount,
  }) {
    final p = _post;

    final m = PostModel(
      id: p.id,
      authorName: p.authorName,
      authorEmoji: p.authorEmoji,
      type: p.type,
      text: p.text,
      timeAgo: p.timeAgo,
      hugCount: hugCount ?? p.hugCount,
      replyCount: replyCount ?? p.replyCount,
      isHugged: isHugged ?? p.isHugged,
      isFeelThis: isFeelThis ?? p.isFeelThis,
      isSaved: isSaved ?? p.isSaved,
      isAnonymous: p.isAnonymous,
      isOwn: p.isOwn,
    );

    m.replies.addAll(p.replies);

    return m;
  }

  Color get _topBorderColor {
    switch (_post.type) {
      case PostType.thought:
        return ArriveColors.postPinkBorder;
      case PostType.support:
        return ArriveColors.postBlueBorder;
      case PostType.win:
        return ArriveColors.postSageBorder;
      case PostType.anonymous:
        return ArriveColors.postPurpleBorder;
    }
  }

  LinearGradient get _avatarGradient {
    if (_post.isAnonymous) return ArriveColors.avE;

    switch (_post.type) {
      case PostType.thought:
        return ArriveColors.avA;
      case PostType.support:
        return ArriveColors.avB;
      case PostType.win:
        return ArriveColors.avC;
      case PostType.anonymous:
        return ArriveColors.avE;
    }
  }

  Future<void> _toggleHug() async {
    if (_isReactingHug) return;

    print('========== TOGGLE HUG START ==========');
    print('POST ID : ${_post.id}');

    setState(() => _isReactingHug = true);

    final oldPost = _post;
    final oldFeelCount = _feelCount;

    final nextHugged = !_post.isHugged;
    final nextHugCount = nextHugged
        ? _post.hugCount + 1
        : (_post.hugCount > 0 ? _post.hugCount - 1 : 0);

    setState(() {
      _post = _copy(
        isHugged: nextHugged,
        hugCount: nextHugCount,
      );
    });

    widget.onChanged(_post);

    try {
      final user = await SessionManager.getUser();
      final userId = int.tryParse(user?['id']?.toString() ?? '') ?? 0;
      final postId = int.tryParse(_post.id.toString()) ?? 0;

      print('USER ID : $userId');
      print('POST ID : $postId');

      if (userId == 0) throw Exception('User not found');
      if (postId == 0) throw Exception('Invalid post id');

      final result = await CommunityReactService.reactToPost(
        userId: userId,
        postId: postId,
        type: 'hug',
      );

      print('HUG API RESULT : $result');

      final reacted = _parseBool(result['reacted']);

      final apiHugCount = int.tryParse(
        result['hug_count']?.toString() ?? '',
      ) ??
          nextHugCount;

      final apiFeelCount = int.tryParse(
        result['feel_count']?.toString() ?? '',
      ) ??
          _feelCount;

      if (!mounted) return;

      setState(() {
        _feelCount = apiFeelCount;

        _post = _copy(
          isHugged: reacted,
          hugCount: apiHugCount,
        );
      });

      widget.onChanged(_post);

      print('========== TOGGLE HUG END ==========');
    } catch (e) {
      print('TOGGLE HUG ERROR: $e');

      if (!mounted) return;

      setState(() {
        _post = oldPost;
        _feelCount = oldFeelCount;
      });

      widget.onChanged(oldPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReactingHug = false);
      }
    }
  }

  Future<void> _toggleFeel() async {
    if (_isReactingFeel) return;

    print('========== TOGGLE FEEL START ==========');
    print('POST ID : ${_post.id}');

    setState(() => _isReactingFeel = true);

    final oldPost = _post;
    final oldFeelCount = _feelCount;

    final nextFeel = !_post.isFeelThis;
    final nextFeelCount = nextFeel
        ? _feelCount + 1
        : (_feelCount > 0 ? _feelCount - 1 : 0);

    setState(() {
      _feelCount = nextFeelCount;

      _post = _copy(
        isFeelThis: nextFeel,
      );
    });

    widget.onChanged(_post);

    try {
      final user = await SessionManager.getUser();
      final userId = int.tryParse(user?['id']?.toString() ?? '') ?? 0;
      final postId = int.tryParse(_post.id.toString()) ?? 0;

      print('USER ID : $userId');
      print('POST ID : $postId');

      if (userId == 0) throw Exception('User not found');
      if (postId == 0) throw Exception('Invalid post id');

      final result = await CommunityReactService.reactToPost(
        userId: userId,
        postId: postId,
        type: 'feel',
      );

      print('FEEL API RESULT : $result');

      final reacted = _parseBool(result['reacted']);

      final apiFeelCount = int.tryParse(
        result['feel_count']?.toString() ?? '',
      ) ??
          nextFeelCount;

      final apiHugCount = int.tryParse(
        result['hug_count']?.toString() ?? '',
      ) ??
          _post.hugCount;

      if (!mounted) return;

      setState(() {
        _feelCount = apiFeelCount;

        _post = _copy(
          isFeelThis: reacted,
          hugCount: apiHugCount,
        );
      });

      widget.onChanged(_post);

      print('========== TOGGLE FEEL END ==========');
    } catch (e) {
      print('TOGGLE FEEL ERROR: $e');

      if (!mounted) return;

      setState(() {
        _feelCount = oldFeelCount;
        _post = oldPost;
      });

      widget.onChanged(oldPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReactingFeel = false);
      }
    }
  }

  bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false) return false;

    final s = value?.toString().toLowerCase().trim();

    return s == '1' || s == 'true' || s == 'yes';
  }

  void _toggleSave() {
    print('========== TOGGLE SAVE ==========');
    print('POST ID   : ${_post.id}');
    print('OLD SAVED : ${_post.isSaved}');

    setState(() {
      _post = _copy(
        isSaved: !_post.isSaved,
      );
    });

    print('NEW SAVED : ${_post.isSaved}');
    print('================================');

    widget.onChanged(_post);
  }

  void _toggleReplyBox() {
    print('========== LOCAL REPLY BOX TOGGLE ==========');
    print('POST ID : ${_post.id}');

    setState(() {
      _showReplyBox = !_showReplyBox;

      if (!_showReplyBox) {
        _showEmojiPicker = false;
      }
    });
  }

  void _addEmoji(String emoji) {
    final text = _replyController.text;
    final selection = _replyController.selection;
    final position = selection.baseOffset < 0 ? text.length : selection.baseOffset;

    _replyController.text = text.replaceRange(position, position, emoji);
    _replyController.selection = TextSelection.collapsed(
      offset: position + emoji.length,
    );
  }

  void _sendReply() {
    final text = _replyController.text.trim();

    if (text.isEmpty) return;

    print('========== LOCAL SEND REPLY ==========');
    print('POST ID : ${_post.id}');
    print('TEXT    : $text');

    setState(() {
      _post.replies.add(
        ReplyModel(
          authorName: 'You',
          authorEmoji: '🩵',
          text: text,
        ),
      );

      _post = _copy(
        replyCount: _post.replyCount + 1,
      );

      _replyController.clear();
      _showEmojiPicker = false;
    });

    widget.onChanged(_post);
  }

  Widget _buildRepliesDropdownButton() {
    final int count = _post.replyCount;

    return GestureDetector(
      onTap: () {
        print('========== REPLIES DROPDOWN TAPPED ==========');
        print('POST ID  : ${_post.id}');
        print('COUNT    : $count');
        print('EXPANDED : ${widget.isRepliesExpanded}');
        print('LOADING  : ${widget.isRepliesLoading}');
        print('============================================');

        widget.onRepliesToggle?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isRepliesExpanded
              ? ArriveColors.blue.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isRepliesExpanded
                ? ArriveColors.blue.withOpacity(0.45)
                : ArriveColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isRepliesLoading) ...[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: ArriveColors.blue,
                ),
              ),
              const SizedBox(width: 7),
            ] else ...[
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 14,
                color: widget.isRepliesExpanded
                    ? ArriveColors.blue
                    : ArriveColors.textMuted,
              ),
              const SizedBox(width: 6),
            ],

            Text(
              '$count replies',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: widget.isRepliesExpanded
                    ? ArriveColors.blue
                    : ArriveColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(width: 4),

            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: widget.isRepliesExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: widget.isRepliesExpanded
                    ? ArriveColors.blue
                    : ArriveColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiRepliesList() {
    if (!widget.isRepliesExpanded) {
      return const SizedBox.shrink();
    }

    if (widget.isRepliesLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ArriveColors.glassBorder),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ArriveColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading replies...',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: ArriveColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.apiReplies.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ArriveColors.glassBorder),
        ),
        child: Row(
          children: [
            const Text(
              '💭',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(width: 8),
            Text(
              'No replies yet.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: ArriveColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ArriveColors.glassBorder,
          ),
        ),
      ),
      child: Column(
        children: widget.apiReplies
            .map((reply) => _ReplyItem(reply: reply))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: ArriveColors.glass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ArriveColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _topBorderColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: _avatarGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ArriveColors.glassBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _post.isAnonymous
                                  ? '🤍'
                                  : (_post.authorEmoji ?? '🌸'),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post.isAnonymous
                                    ? 'Anonymous Mom'
                                    : (_post.isOwn
                                    ? '${_post.authorName} (you)'
                                    : (_post.authorName ?? '')),
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ArriveColors.text,
                                ),
                              ),
                              Text(
                                _post.timeAgo,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                  color: ArriveColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            GestureDetector(
                              onTap: _toggleSave,
                              child: AnimatedOpacity(
                                opacity: _post.isSaved ? 1.0 : 0.35,
                                duration: const Duration(milliseconds: 200),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    '🔖',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: widget.onReplyTap ?? _toggleReplyBox,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  ArriveColors.glassBorder.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: const Color(0xFF8DBFAA),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.message,
                                      size: 13,
                                      color: Color(0xFF8DBFAA),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add Replies',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF8DBFAA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    _buildBadge(),

                    Text(
                      _post.text,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        height: 1.75,
                        color: ArriveColors.textSoft,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        _ReactionBtn(
                          label: '🤗  ${_post.hugCount}',
                          isActive: _post.isHugged,
                          isLoading: _isReactingHug,
                          activeColor: ArriveColors.pink,
                          onTap: _toggleHug,
                        ),

                        const SizedBox(width: 8),

                        _ReactionBtn(
                          label: '🕊️  I feel this  $_feelCount',
                          isActive: _post.isFeelThis,
                          isLoading: _isReactingFeel,
                          activeColor: ArriveColors.blue,
                          onTap: _toggleFeel,
                        ),

                        const Spacer(),

                        _buildRepliesDropdownButton(),
                      ],
                    ),

                    if (_showReplyBox) ...[
                      const SizedBox(height: 13),
                      _buildReplyBox(),
                    ],

                    if (_showEmojiPicker) ...[
                      const SizedBox(height: 10),
                      _buildEmojiPicker(),
                    ],

                    _buildApiRepliesList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    late String label;
    late Color color;

    switch (_post.type) {
      case PostType.thought:
        label = '💭 Thought';
        color = ArriveColors.pink;
        break;
      case PostType.support:
        label = '🤝 Need Support';
        color = ArriveColors.blue;
        break;
      case PostType.win:
        label = '✨ Share a Win';
        color = ArriveColors.sage;
        break;
      case PostType.anonymous:
        label = '🤍 Anonymous';
        color = ArriveColors.purple;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.7,
          color: color,
        ),
      ),
    );
  }

  Widget _buildReplyBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ArriveColors.glassBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showEmojiPicker = !_showEmojiPicker;
              });
            },
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 22,
              color: ArriveColors.textMuted,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _replyController,
              minLines: 1,
              maxLines: 4,
              cursorColor: ArriveColors.sage,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: ArriveColors.text,
              ),
              decoration: InputDecoration(
                hintText: 'Type a reply...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: ArriveColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: _sendReply,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ArriveColors.sage.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ArriveColors.sage.withOpacity(0.45),
                ),
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 17,
                color: Color(0xFF8DBFAA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ArriveColors.glassBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _emojis.map((emoji) {
          return GestureDetector(
            onTap: () => _addEmoji(emoji),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ArriveColors.glass,
                shape: BoxShape.circle,
                border: Border.all(color: ArriveColors.glassBorder),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLoading;
  final Color activeColor;
  final VoidCallback onTap;

  const _ReactionBtn({
    required this.label,
    required this.isActive,
    required this.isLoading,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedOpacity(
          opacity: isLoading ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.12)
                  : Colors.transparent,
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacity(0.5)
                    : ArriveColors.glassBorder,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : ArriveColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyItem extends StatelessWidget {
  final ReplyModel reply;

  const _ReplyItem({
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ArriveColors.glass,
              shape: BoxShape.circle,
              border: Border.all(color: ArriveColors.glassBorder),
            ),
            child: Center(
              child: Text(
                reply.authorEmoji,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.035),
                border: Border.all(color: ArriveColors.glassBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.authorName,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ArriveColors.text,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    reply.text,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: ArriveColors.textSoft,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}