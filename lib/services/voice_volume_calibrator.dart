import '../models/voice_volume_calibration.dart';
import 'voice_analysis_engine.dart';

enum VolumeZone { low, transition, ideal, high }

/// Centro da faixa ideal de volume (-35 a -10 dB).
double get idealCenterDb =>
    (VoiceAnalysisThresholds.volumeLowDb +
            VoiceAnalysisThresholds.volumeHighDb) /
        2;

VoiceVolumeCalibration buildCalibration(double referenceDb) {
  return VoiceVolumeCalibration(
    referenceDb: referenceDb,
    offsetDb: idealCenterDb - referenceDb,
    calibratedAt: DateTime.now(),
  );
}

double applyCalibration(double rawDb, VoiceVolumeCalibration? calibration) {
  if (calibration == null) return rawDb;
  return rawDb + calibration.offsetDb;
}

VolumeZone classifyVolumeZone(double db) {
  const low = VoiceAnalysisThresholds.volumeLowDb;
  const high = VoiceAnalysisThresholds.volumeHighDb;
  const margin = 3.0;

  if (db >= low && db <= high) return VolumeZone.ideal;
  if (db < low - margin) return VolumeZone.low;
  if (db > high + margin) return VolumeZone.high;
  return VolumeZone.transition;
}

String volumeZoneLabel(VolumeZone zone) {
  switch (zone) {
    case VolumeZone.low:
      return 'Volume baixo — fale mais alto';
    case VolumeZone.transition:
      return 'Quase lá — ajuste um pouco';
    case VolumeZone.ideal:
      return 'Volume ideal';
    case VolumeZone.high:
      return 'Volume alto — modere';
  }
}

/// Meta padrão de segundos no volume ideal durante o teste.
const int defaultIdealVolumeGoalSeconds = 5;
