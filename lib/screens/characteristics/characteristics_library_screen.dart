import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/oratory_characteristic.dart';
import '../../providers/oratory_guide_provider.dart';
import '../../services/characteristics_service.dart';
import '../tools/bet_guide/characteristic_detail_screen.dart';
import '../tools/bet_guide/self_assessment_screen.dart';

class CharacteristicsLibraryScreen extends StatefulWidget {
  const CharacteristicsLibraryScreen({super.key});

  @override
  State<CharacteristicsLibraryScreen> createState() =>
      _CharacteristicsLibraryScreenState();
}

class _CharacteristicsLibraryScreenState
    extends State<CharacteristicsLibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OratoryGuideProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = CharacteristicsService.instance;
    final categories = service.allCategories;
    
    List<OratoryCharacteristic> characteristics;
    if (_searchQuery.isNotEmpty) {
      characteristics = service.searchCharacteristics(_searchQuery);
    } else if (_selectedCategoryId != null) {
      characteristics = service.getCharacteristicsByCategory(_selectedCategoryId!);
    } else {
      characteristics = service.allCharacteristics;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('53 Características'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check),
            tooltip: 'Autoavaliação',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SelfAssessmentScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Consumer<OratoryGuideProvider>(
              builder: (context, guide, _) {
                if (guide.weeklyFocusIds.isEmpty) return const SizedBox.shrink();
                return Card(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Foco da semana: ${guide.weeklyFocusIds.length} característica(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar características...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(
                  label: 'Todas',
                  isSelected: _selectedCategoryId == null,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
                ...categories.map((cat) {
                  return _CategoryChip(
                    label: cat.name,
                    isSelected: _selectedCategoryId == cat.id,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.id;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${characteristics.length} características',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Livro be-T',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: characteristics.length,
              itemBuilder: (context, index) {
                final char = characteristics[index];
                return _CharacteristicCard(characteristic: char);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
      ),
    );
  }
}

class _CharacteristicCard extends StatelessWidget {
  final OratoryCharacteristic characteristic;

  const _CharacteristicCard({required this.characteristic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: Text('${characteristic.id}'),
        ),
        title: Text(
          characteristic.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${characteristic.category} · Pág. ${characteristic.pageReference}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                CharacteristicDetailScreen(characteristic: characteristic),
          ),
        ),
      ),
    );
  }
}

