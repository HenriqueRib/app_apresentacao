import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal_weekly_goal.dart';
import '../screens/tools/bet_guide/voice_rehearsal_screen.dart';
import '../services/storage_service.dart';

class VoiceRehearsalWeeklyProgressCard extends StatefulWidget {
  const VoiceRehearsalWeeklyProgressCard({super.key});

  @override
  State<VoiceRehearsalWeeklyProgressCard> createState() =>
      _VoiceRehearsalWeeklyProgressCardState();
}

class _VoiceRehearsalWeeklyProgressCardState
    extends State<VoiceRehearsalWeeklyProgressCard> {
  int _count = 0;
  VoiceRehearsalWeeklyGoal _goal = VoiceRehearsalWeeklyGoal.defaults;
  bool _smartWeekly = false;
  bool _loading = true;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final count = await storage.countVoiceRehearsalAttemptsThisWeek();
    final goal = await storage.getVoiceRehearsalWeeklyGoal();
    final flags = await storage.getVoiceRehearsalSmartFlags();
    final streak = await storage.getVoiceRehearsalStreak();
    if (mounted) {
      setState(() {
        _count = count;
        _goal = goal;
        _smartWeekly = flags.weeklyGoalEnabled;
        _streakDays = streak.consecutiveDays;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || (!_smartWeekly && !_goal.enabled)) {
      return const SizedBox.shrink();
    }

    final target = _goal.targetCount;
    final progress = target > 0 ? (_count / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VoiceRehearsalScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Ensaio be-T esta semana',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '$_count / $target',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: progress >= 1
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                progress >= 1
                    ? 'Meta semanal concluída!'
                    : 'Faltam ${(target - _count).clamp(0, target)} ensaio(s) para a meta.',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              if (_streakDays >= 2) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 14, color: AppTheme.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'Streak: $_streakDays dia(s) seguidos de ensaio',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VoiceRehearsalScreen(
                        initialDurationGoalSeconds: 240,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.timer_outlined, size: 16),
                  label: const Text(
                    'Ensaio 4 min',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
