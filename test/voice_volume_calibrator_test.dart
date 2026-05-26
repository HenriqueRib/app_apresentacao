import 'package:flutter_test/flutter_test.dart';
import 'package:palestrante_de_sucesso/models/voice_volume_calibration.dart';
import 'package:palestrante_de_sucesso/services/voice_volume_calibrator.dart';

void main() {
  test('buildCalibration calcula offset para centro ideal', () {
    const referenceDb = -40.0;
    final cal = buildCalibration(referenceDb);
    expect(cal.referenceDb, referenceDb);
    expect(cal.offsetDb, closeTo(idealCenterDb - referenceDb, 0.01));
  });

  test('applyCalibration ajusta dB com offset', () {
    final cal = VoiceVolumeCalibration(
      referenceDb: -40,
      offsetDb: idealCenterDb - (-40),
      calibratedAt: DateTime.now(),
    );
    expect(applyCalibration(-40, cal), closeTo(idealCenterDb, 0.01));
  });

  test('classifyVolumeZone retorna ideal na faixa', () {
    expect(classifyVolumeZone(-25), VolumeZone.ideal);
    expect(classifyVolumeZone(-50), VolumeZone.low);
    expect(classifyVolumeZone(-5), VolumeZone.high);
  });

  test('meta padrão de segundos no verde', () {
    expect(defaultIdealVolumeGoalSeconds, 5);
  });
}
