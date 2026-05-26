import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/s315_speaker_feedback.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal_online_analysis.dart';

void main() {
  group('VoiceRehearsalOnlineAnalysis', () {
    test('fromApiResponse parseia resposta do backend', () {
      final analysis = VoiceRehearsalOnlineAnalysis.fromApiResponse({
        'pontos_fortes': ['Clareza na introdução'],
        'pontos_melhorar': ['Reduzir muletas'],
        'proximos_passos': ['Ensaiar conclusão com chamada à ação'],
        'estrutura': {
          'introducao': {
            'status': 'ok',
            'comentario': 'Introdução envolvente.',
          },
          'conclusao': {
            'status': 'atencao',
            'comentario': 'Conclusão genérica.',
          },
        },
        'caracteristicas_be_t': [
          {
            'id': 38,
            'titulo': 'Introdução',
            'nota': 'B+',
            'evidencia': 'Pergunta retórica no início.',
            'sugestao': 'Manter gancho inicial.',
          },
        ],
        's315_enriquecido': {
          'habilidade_orador': 'Tom bondoso e claro.',
          'personalidade': 'Demonstra humildade ao falar.',
          'aspectos': [
            {
              'label': 'Clareza bíblica',
              'status': 'ok',
              'detail': 'Referências bem explicadas.',
            },
          ],
        },
        'disclaimer': 'Rascunho auxiliar.',
        'backend_version': '2026.05.1',
      });

      expect(analysis.pontosFortes, ['Clareza na introdução']);
      expect(analysis.pontosMelhorar, ['Reduzir muletas']);
      expect(analysis.proximosPassos, hasLength(1));
      expect(analysis.estruturaComentarios, hasLength(2));
      expect(analysis.caracteristicasBeT.first.id, 38);
      expect(analysis.caracteristicasBeT.first.nota, 'B+');
      expect(analysis.s315Enriquecido?.habilidadeOrador, contains('bondoso'));
      expect(analysis.s315Enriquecido?.aspectos.first.status,
          S315AspectStatus.ok);
      expect(analysis.disclaimer, 'Rascunho auxiliar.');
      expect(analysis.backendVersion, '2026.05.1');
    });

    test('toJson e fromJson são simétricos', () {
      final original = VoiceRehearsalOnlineAnalysis(
        analyzedAt: DateTime(2026, 5, 25, 14, 30),
        pontosFortes: const ['Fluência'],
        pontosMelhorar: const ['Volume'],
        proximosPassos: const ['Calibrar microfone'],
        caracteristicasBeT: const [
          VoiceRehearsalOnlineCharacteristic(
            id: 4,
            titulo: 'Ritmo',
            nota: 'A-',
          ),
        ],
        estruturaComentarios: const [
          VoiceRehearsalOnlineStructureComment(
            secao: 'introducao',
            status: 'ok',
            comentario: 'Bom gancho.',
          ),
        ],
        s315Enriquecido: const VoiceRehearsalOnlineS315Enriched(
          habilidadeOrador: 'Orador claro.',
          personalidade: 'Equilibrado.',
        ),
      );

      final restored =
          VoiceRehearsalOnlineAnalysis.fromJson(original.toJson());

      expect(restored.pontosFortes, original.pontosFortes);
      expect(restored.caracteristicasBeT.first.nota, 'A-');
      expect(restored.s315Enriquecido?.personalidade, 'Equilibrado.');
    });
  });
}
