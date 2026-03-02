import 'package:equatable/equatable.dart';

class CopilotEvent {
  const CopilotEvent({required this.eventType, required this.payload, this.timestamp});
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime? timestamp;
  Map<String, dynamic> toJson() => {'event_type': eventType, 'payload': payload, 'timestamp': (timestamp ?? DateTime.now()).toIso8601String()};
}

class Recommendation extends Equatable {
  const Recommendation({required this.id, required this.type, required this.title, this.description, this.score, this.reason, this.actionUrl, this.metadata = const {}});
  final String id;
  final String type;
  final String title;
  final String? description;
  final double? score;
  final String? reason;
  final String? actionUrl;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [id, type];

  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
    id: '${j['id'] ?? ''}', type: j['type'] as String? ?? 'unknown',
    title: j['title'] as String? ?? '', description: j['description'] as String?,
    score: (j['score'] as num?)?.toDouble(), reason: j['reason'] as String?,
    actionUrl: j['action_url'] as String?, metadata: j['metadata'] as Map<String, dynamic>? ?? {},
  );
}

class CopilotContext {
  const CopilotContext({this.userId, this.leadScore, this.nextAction, this.summary});
  final String? userId;
  final double? leadScore;
  final String? nextAction;
  final String? summary;
  factory CopilotContext.fromJson(Map<String, dynamic> j) => CopilotContext(
    userId: j['user_id'] as String?, leadScore: (j['lead_score'] as num?)?.toDouble(),
    nextAction: j['next_action'] as String?, summary: j['summary'] as String?,
  );
}
