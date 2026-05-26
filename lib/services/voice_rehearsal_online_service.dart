import '../core/utils/api_http_helper.dart';
import '../models/voice_rehearsal_attempt.dart';
import '../models/voice_rehearsal_online_analysis.dart';
import 'ensino_api.dart';
import 'voice_rehearsal_online_payload_builder.dart';

class VoiceRehearsalOnlineService {
  final EnsinoApi _api;

  VoiceRehearsalOnlineService({EnsinoApi? api}) : _api = api ?? EnsinoApi();

  Future<VoiceRehearsalOnlineAnalysis> analyze(VoiceRehearsalAttempt attempt) {
    final payload = VoiceRehearsalOnlinePayloadBuilder.build(attempt);
    return _api.analisarEnsaioOnline(payload);
  }

  static String userMessageFor(Object error) {
    if (error is VoiceRehearsalOnlinePayloadException) {
      return error.message;
    }
    if (error is ApiNotFoundException) {
      return 'Recurso ainda não disponível no servidor.';
    }
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('Connection refused') ||
        text.contains('TimeoutException')) {
      return 'Sem conexão. Análise local permanece disponível.';
    }
    return 'Não foi possível concluir a análise online. Tente novamente.';
  }
}
