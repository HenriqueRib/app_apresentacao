import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/oratory_characteristic.dart';
import '../../services/characteristics_service.dart';

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
      ),
      body: Column(
        children: [
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
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: Text('${characteristic.id}'),
        ),
        title: Text(
          characteristic.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                characteristic.category,
                style: const TextStyle(fontSize: 10, color: AppTheme.accentColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pág. ${characteristic.pageReference}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.play_arrow,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'O que fazer:',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(characteristic.action),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb,
                              color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Por que é importante:',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(characteristic.importance),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
