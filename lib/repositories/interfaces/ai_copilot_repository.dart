import '../../models/ai_copilot/ai_copilot.dart';

abstract class AiCopilotRepository {
  Future<void> publishEvent(CopilotEvent event);
  Future<List<Recommendation>> getRecommendations({String? type});
  Future<CopilotContext> getContext();
}
