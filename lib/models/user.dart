// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class User {
  final String playfabId;
  final List<String> aliasHistory;
  final String aliasHistoryRaw;
  User({
    required this.playfabId,
    required this.aliasHistory,
    required this.aliasHistoryRaw,
  });

  User copyWith({
    String? playfabId,
    List<String>? aliasHistory,
  }) {
    return User(
      playfabId: playfabId ?? this.playfabId,
      aliasHistory: aliasHistory ?? this.aliasHistory,
      aliasHistoryRaw: aliasHistoryRaw,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playfabId': playfabId,
      'aliasHistory': "$aliasHistory",
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      playfabId: map['playfabId'] as String,
      aliasHistory: formatAliases(map['aliasHistory']),
      aliasHistoryRaw: map['aliasHistory'],
    );
  }

  static List<String> formatAliases(String aliases) {
    return aliases.split(",");
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(playfabId: $playfabId, aliasHistory: $aliasHistory)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.playfabId == playfabId &&
      listEquals(other.aliasHistory, aliasHistory);
  }

  @override
  int get hashCode => playfabId.hashCode ^ aliasHistory.hashCode;
}
