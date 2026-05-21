import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/meeting_hub_provider.dart';
import 'meeting_comentarios_tab.dart';
import 'meeting_respostas_tab.dart';

class MeetingHubScreen extends StatefulWidget {
  const MeetingHubScreen({super.key});

  @override
  State<MeetingHubScreen> createState() => _MeetingHubScreenState();
}

class _MeetingHubScreenState extends State<MeetingHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingHubProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Central da Reunião'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Comentários', icon: Icon(Icons.event_note)),
            Tab(text: 'Respostas', icon: Icon(Icons.question_answer)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MeetingComentariosTab(),
          MeetingRespostasTab(),
        ],
      ),
    );
  }
}
