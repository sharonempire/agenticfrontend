import '../../core/network/fastapi_client.dart';
import '../../models/ai_copilot/ai_copilot.dart';
import '../ai_copilot_repository.dart';

/// FastAPI-backed AI copilot repository.
/// Maps /api/v1/ai-copilot/* endpoints.
class FastApiAiCopilotRepository implements AiCopilotRepository {
  FastApiAiCopilotRepository({required this.client});

  final FastApiClient client;

  @override
  Future<void> publishEvent(CopilotEvent event) async {
    await client.post<dynamic>(
      '/ai-copilot/events',
      data: event.toJson(),
    );
  }

  @override
  Future<void> publishEventsBatch(List<CopilotEvent> events) async {
    await client.post<dynamic>(
      '/ai-copilot/events/batch',
      data: {'events': events.map((e) => e.toJson()).toList()},
    );
  }

  @override
  Future<List<Recommendation>> getRecommendations({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final response = await client.get<dynamic>(
      '/ai-copilot/recommendations',
      queryParameters: params.isNotEmpty ? params : null,
    );

    final data = response.data;
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(Recommendation.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['recommendations'] as List? ??
          data['items'] as List? ??
          data['results'] as List? ??
          [];
      return items
          .cast<Map<String, dynamic>>()
          .map(Recommendation.fromJson)
          .toList();
    }
    return [];
  }

  @override
  Future<CopilotContext> getContext() async {
    final response = await client.get<Map<String, dynamic>>(
      '/ai-copilot/context',
    );
    return CopilotContext.fromJson(response.data!);
  }

  @override
  Future<String?> getNextAction() async {
    final response = await client.get<Map<String, dynamic>>(
      '/ai-copilot/next-action',
    );
    return response.data?['action'] as String?;
  }

  @override
  Future<double?> getLeadScore(String leadId) async {
    final response = await client.get<Map<String, dynamic>>(
      '/ai-copilot/lead-score',
      queryParameters: {'lead_id': leadId},
    );
    return (response.data?['score'] as num?)?.toDouble();
  }

  @override
  Future<EmailDraft> generateEmailDraft(Map<String, dynamic> params) async {
    final response = await client.post<Map<String, dynamic>>(
      '/ai-copilot/email-draft',
      data: params,
    );
    return EmailDraft.fromJson(response.data!);
  }
}
