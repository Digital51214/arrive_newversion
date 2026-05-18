import 'package:flutter/foundation.dart';

enum PostType {
  thought,
  support,
  win,
  anonymous,
}

@immutable
class ReplyModel {
  final String authorName;
  final String authorEmoji;
  final String text;

  const ReplyModel({
    required this.authorName,
    required this.authorEmoji,
    required this.text,
  });

  ReplyModel copyWith({
    String? authorName,
    String? authorEmoji,
    String? text,
  }) {
    return ReplyModel(
      authorName: authorName ?? this.authorName,
      authorEmoji: authorEmoji ?? this.authorEmoji,
      text: text ?? this.text,
    );
  }
}

class PostModel {
  final String id;
  final String? authorName;
  final String? authorEmoji;
  final PostType type;
  final String text;
  final String timeAgo;
  final int hugCount;
  final int replyCount;
  final bool isHugged;
  final bool isFeelThis;
  final bool isSaved;
  final bool isAnonymous;
  final bool isOwn;

  /// Mutable copy, so UI code can safely add replies without
  /// "Unsupported operation: Cannot add to an unmodifiable list".
  final List<ReplyModel> replies;

  PostModel({
    required this.id,
    required this.authorName,
    required this.authorEmoji,
    required this.type,
    required this.text,
    required this.timeAgo,
    required this.hugCount,
    required this.replyCount,
    required this.isHugged,
    required this.isFeelThis,
    required this.isSaved,
    required this.isAnonymous,
    this.isOwn = false,
    List<ReplyModel>? replies,
  }) : replies = List<ReplyModel>.from(replies ?? const []);

  PostModel copyWith({
    String? id,
    String? authorName,
    String? authorEmoji,
    PostType? type,
    String? text,
    String? timeAgo,
    int? hugCount,
    int? replyCount,
    bool? isHugged,
    bool? isFeelThis,
    bool? isSaved,
    bool? isAnonymous,
    bool? isOwn,
    List<ReplyModel>? replies,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorEmoji: authorEmoji ?? this.authorEmoji,
      type: type ?? this.type,
      text: text ?? this.text,
      timeAgo: timeAgo ?? this.timeAgo,
      hugCount: hugCount ?? this.hugCount,
      replyCount: replyCount ?? this.replyCount,
      isHugged: isHugged ?? this.isHugged,
      isFeelThis: isFeelThis ?? this.isFeelThis,
      isSaved: isSaved ?? this.isSaved,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isOwn: isOwn ?? this.isOwn,
      replies: replies ?? this.replies,
    );
  }
}
