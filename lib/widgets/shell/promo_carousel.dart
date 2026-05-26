import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../screens/tools/assentinel/assentinel_screen.dart';
import '../../screens/tools/bet_guide/voice_rehearsal_screen.dart';
import '../../screens/tools/meeting/meeting_hub_screen.dart';

const _kPromoDismissedKey = 'promo_carousel_dismissed';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dismissed = false;
  bool _loaded = false;
  WeeklyCommentsResponse? _weeklyComments;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_kPromoDismissedKey) ?? false;
    WeeklyCommentsResponse? comments;
    try {
      comments = await ApiService().getWeeklyComments();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _dismissed = dismissed;
        _weeklyComments = comments;
        _loaded = true;
      });
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPromoDismissedKey, true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _dismissed) return const SizedBox.shrink();

    final slides = _buildSlides(context);
    if (slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) => slides[index],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.shellAccentTeal
                    : AppTheme.shellTextSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> _buildSlides(BuildContext context) {
    return [
      _PromoSlide(
        title: 'Ensaie. Avalie. Evolua.',
        subtitle:
            'Use os recursos be-T para treinar e medir seu desempenho.',
        accentColor: AppTheme.shellAccentTeal,
        trailing: const Icon(
          Icons.trending_up,
          color: AppTheme.shellAccentTeal,
          size: 48,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VoiceRehearsalScreen()),
        ),
        onClose: _dismiss,
      ),
      if (_weeklyComments != null)
        _PromoSlide(
          title: 'Comentários da semana',
          subtitle: _weeklyComments!.semana,
          body: _weeklyComments!.comentarioTexts.isEmpty
              ? 'Sem comentários cadastrados para esta semana.'
              : _weeklyComments!.comentarioTexts.take(2).join('\n'),
          accentColor: AppTheme.primaryColor,
          trailing: const Icon(
            Icons.event_note,
            color: AppTheme.shellAccentTeal,
            size: 40,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MeetingHubScreen()),
          ),
          onClose: _dismiss,
        ),
      _PromoSlide(
        title: 'A Sentinela',
        subtitle: 'Estudos semanais e comentários para sua preparação.',
        accentColor: Colors.teal,
        trailing: const Icon(
          Icons.auto_stories,
          color: AppTheme.shellAccentTeal,
          size: 40,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AssentinelScreen()),
        ),
        onClose: _dismiss,
      ),
    ];
  }
}

class _PromoSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? body;
  final Color accentColor;
  final Widget trailing;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _PromoSlide({
    required this.title,
    required this.subtitle,
    this.body,
    required this.accentColor,
    required this.trailing,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppTheme.shellSurfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.shellAccentTeal.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 56, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.shellTextPrimary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (body != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            body!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing,
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppTheme.shellTextSecondary,
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
