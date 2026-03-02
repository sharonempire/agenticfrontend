import '../models/ai_copilot/ai_copilot.dart';

/// Abstract contract for AI copilot features.
abstract class AiCopilotRepository {
  Future<void> publishEvent(CopilotEvent event);
  Future<void> publishEventsBatch(List<CopilotEvent> events);
  Future<List<Recommendation>> getRecommendations({String? type});
  Future<CopilotContext> getContext();
  Future<String?> getNextAction();
  Future<double?> getLeadScore(String leadId);
  Future<EmailDraft> generateEmailDraft(Map<String, dynamic> params);
}
