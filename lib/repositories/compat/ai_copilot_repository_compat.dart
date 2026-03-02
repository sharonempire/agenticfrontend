import 'dart:collection';

import 'package:logger/logger.dart';

import '../../config/feature_flags.dart';
import '../../core/error/app_exception.dart';
import '../../models/ai_copilot/ai_copilot.dart';
import '../ai_copilot_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Compatibility adapter for AI copilot.
///
/// Unlike Course/Job compat repos, there is NO Supabase fallback for AI features.
/// If the feature flag is off or the backend is unreachable, calls return
/// safe empty/null defaults — they never crash the app.
class AiCopilotRepositoryCompat implements AiCopilotRepository {
  AiCopilotRepositoryCompat({required this.fastApi});

  final AiCopilotRepository fastApi;

  /// Local offline queue for events that couldn't be published.
  final Queue<CopilotEvent> _offlineQueue = Queue<CopilotEvent>();

  bool get _enabled => FeatureFlags.aiCopilot;

  @override
  Future<void> publishEvent(CopilotEvent event) async {
    if (!_enabled) return;
    try {
      // First, flush any queued events.
      await _flushQueue();
      await fastApi.publishEvent(event);
    } on AppException catch (e) {
      _log.w('[AiCopilot.publishEvent] Failed ($e), queuing locally');
      _offlineQueue.add(event);
    }
  }

  @override
  Future<void> publishEventsBatch(List<CopilotEvent> events) async {
    if (!_enabled) return;
    try {
      await _flushQueue();
      await fastApi.publishEventsBatch(events);
    } on AppException catch (e) {
      _log.w('[AiCopilot.publishEventsBatch] Failed ($e), queuing ${events.length} events');
      _offlineQueue.addAll(events);
    }
  }

  @override
  Future<List<Recommendation>> getRecommendations({String? type}) async {
    if (!_enabled) return [];
    try {
      return await fastApi.getRecommendations(type: type);
    } on AppException catch (e) {
      _log.w('[AiCopilot.getRecommendations] Failed ($e), returning empty');
      return [];
    }
  }

  @override
  Future<CopilotContext> getContext() async {
    if (!_enabled) return const CopilotContext();
    try {
      return await fastApi.getContext();
    } on AppException catch (e) {
      _log.w('[AiCopilot.getContext] Failed ($e), returning empty');
      return const CopilotContext();
    }
  }

  @override
  Future<String?> getNextAction() async {
    if (!_enabled) return null;
    try {
      return await fastApi.getNextAction();
    } on AppException catch (e) {
      _log.w('[AiCopilot.getNextAction] Failed ($e)');
      return null;
    }
  }

  @override
  Future<double?> getLeadScore(String leadId) async {
    if (!_enabled) return null;
    try {
      return await fastApi.getLeadScore(leadId);
    } on AppException catch (e) {
      _log.w('[AiCopilot.getLeadScore] Failed ($e)');
      return null;
    }
  }

  @override
  Future<EmailDraft> generateEmailDraft(Map<String, dynamic> params) async {
    if (!_enabled) {
      return const EmailDraft(subject: '', body: '');
    }
    // This one propagates errors — the UI should show failure to generate.
    return fastApi.generateEmailDraft(params);
  }

  /// Attempt to flush the offline event queue.
  Future<void> _flushQueue() async {
    if (_offlineQueue.isEmpty) return;
    final batch = _offlineQueue.toList();
    try {
      await fastApi.publishEventsBatch(batch);
      _offlineQueue.clear();
      _log.i('[AiCopilot] Flushed ${batch.length} queued events');
    } catch (_) {
      // Keep in queue for next attempt.
    }
  }
}
