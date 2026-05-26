import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';

class CycleStepData {
  final int step;
  final String title;
  final String description;
  final VoidCallback onTap;

  const CycleStepData({
    required this.step,
    required this.title,
    required this.description,
    required this.onTap,
  });
}

class PerformanceCycleCard extends StatefulWidget {
  final List<CycleStepData> steps;
  final int activeStep;
  final String? focusSpeechTitle;
  final VoidCallback? onViewAllSteps;

  const PerformanceCycleCard({
    super.key,
    required this.steps,
    required this.activeStep,
    this.focusSpeechTitle,
    this.onViewAllSteps,
  });

  static int activeStepFromStatus(SpeechStatus? status) {
    switch (status) {
      case SpeechStatus.planning:
        return 1;
      case SpeechStatus.preparing:
        return 2;
      case SpeechStatus.training:
        return 3;
      case SpeechStatus.ready:
        return 4;
      case SpeechStatus.executed:
      case SpeechStatus.archived:
        return 5;
      case null:
        return 1;
    }
  }

  @override
  State<PerformanceCycleCard> createState() => _PerformanceCycleCardState();
}

class _PerformanceCycleCardState extends State<PerformanceCycleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Seu Ciclo de Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllSteps,
                child: Text(
                  'Ver etapas >',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (widget.focusSpeechTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              'Discurso em foco: ${widget.focusSpeechTitle}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.steps.length; i++) ...[
                  _StepItem(
                    data: widget.steps[i],
                    isActive: widget.steps[i].step == widget.activeStep,
                    isCompleted: widget.steps[i].step < widget.activeStep,
                    pulse: widget.steps[i].step == widget.activeStep
                        ? _pulse
                        : null,
                  ),
                  if (i < widget.steps.length - 1)
                    _StepConnector(
                      isCompleted: widget.steps[i].step < widget.activeStep,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;

  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, left: 4, right: 4),
      child: SizedBox(
        width: 32,
        child: CustomPaint(
          painter: _DashedLinePainter(
            color: isCompleted
                ? AppTheme.shellAccentTeal
                : Colors.grey.shade300,
          ),
          size: const Size(32, 2),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _StepItem extends StatelessWidget {
  final CycleStepData data;
  final bool isActive;
  final bool isCompleted;
  final Animation<double>? pulse;

  const _StepItem({
    required this.data,
    required this.isActive,
    required this.isCompleted,
    this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isActive || isCompleted
        ? AppTheme.shellAccentTeal
        : Colors.grey.shade200;
    final textColor = isActive || isCompleted
        ? AppTheme.primaryColor
        : AppTheme.textSecondary;
    final numberColor =
        isActive || isCompleted ? Colors.white : Colors.grey.shade500;

    Widget circle = GestureDetector(
      onTap: data.onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.shellAccentTeal.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${data.step}',
            style: TextStyle(
              color: numberColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );

    if (pulse != null) {
      circle = ScaleTransition(scale: pulse!, child: circle);
    }

    return SizedBox(
      width: 120,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 8),
          Text(
            data.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
