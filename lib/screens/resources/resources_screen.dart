import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/creative_resource.dart';
import '../../providers/resource_provider.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositório de Recursos'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Títulos Fortes'),
            Tab(text: 'Casos Ilustrativos'),
            Tab(text: 'Repertório'),
            Tab(text: 'Multimídia'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDepthIndicator(),
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResourceList(ResourceType.strongTitle),
                _buildResourceList(ResourceType.illustrativeCase),
                _buildResourceList(ResourceType.connectionRepertoire),
                _buildResourceList(ResourceType.multimediaAsset),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddResourceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDepthIndicator() {
    return Consumer<ResourceProvider>(
      builder: (context, provider, _) {
        if (!provider.hasDepthWarning) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppTheme.warningColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerta de Profundidade',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'O conteúdo original está abaixo de 60%. Adicione mais conteúdo profundo e autêntico.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar recursos...',
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
    );
  }

  Widget _buildResourceList(ResourceType type) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, _) {
        List<CreativeResource> resources;
        
        switch (type) {
          case ResourceType.strongTitle:
            resources = provider.strongTitles;
          case ResourceType.illustrativeCase:
            resources = provider.illustrativeCases;
          case ResourceType.connectionRepertoire:
            resources = provider.connectionRepertoire;
          case ResourceType.multimediaAsset:
            resources = provider.multimediaAssets;
        }

        if (_searchQuery.isNotEmpty) {
          resources = resources.where((r) {
            return r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.content.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (resources.isEmpty) {
          return _buildEmptyState(type);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            return _ResourceCard(
              resource: resources[index],
              onEdit: () => _showEditResourceDialog(context, resources[index]),
              onDelete: () => _confirmDelete(context, resources[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ResourceType type) {
    String title;
    String description;
    IconData icon;

    switch (type) {
      case ResourceType.strongTitle:
        title = 'Nenhum título forte';
        description = 'Adicione chamadas de alto impacto para suas apresentações.';
        icon = Icons.title;
      case ResourceType.illustrativeCase:
        title = 'Nenhum caso ilustrativo';
        description = 'Salve histórias e exemplos reais para ilustrar seus pontos.';
        icon = Icons.auto_stories;
      case ResourceType.connectionRepertoire:
        title = 'Nenhum repertório';
        description = 'Adicione piadas, anedotas e referências de conexão.';
        icon = Icons.emoji_emotions;
      case ResourceType.multimediaAsset:
        title = 'Nenhum asset multimídia';
        description = 'Organize vídeos e trilhas para ritmo e intensidade.';
        icon = Icons.video_library;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddResourceDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    ResourceType selectedType = ResourceType.values[_tabController.index];
    bool isOriginal = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo Recurso',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ResourceType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: ResourceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Conteúdo'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Conteúdo Original'),
                    subtitle: const Text(
                      'Marque se é conteúdo autêntico e profundo',
                    ),
                    value: isOriginal,
                    onChanged: (bool? value) {
                      setModalState(() {
                        isOriginal = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty) return;

                        final provider = context.read<ResourceProvider>();
                        await provider.createResource(
                          type: selectedType,
                          title: titleController.text,
                          content: contentController.text,
                          isOriginal: isOriginal,
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditResourceDialog(BuildContext context, CreativeResource resource) {
    final titleController = TextEditingController(text: resource.title);
    final contentController = TextEditingController(text: resource.content);
    bool isOriginal = resource.isOriginal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar Recurso',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Conteúdo'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Conteúdo Original'),
                    value: isOriginal,
                    onChanged: (bool? value) {
                      setModalState(() {
                        isOriginal = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final provider = context.read<ResourceProvider>();
                        await provider.updateResource(
                          resource.copyWith(
                            title: titleController.text,
                            content: contentController.text,
                            isOriginal: isOriginal,
                          ),
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CreativeResource resource) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir recurso?'),
          content: Text('Tem certeza que deseja excluir "${resource.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<ResourceProvider>();
                await provider.deleteResource(resource.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  String _getTypeName(ResourceType type) {
    switch (type) {
      case ResourceType.strongTitle:
        return 'Título Forte';
      case ResourceType.illustrativeCase:
        return 'Caso Ilustrativo';
      case ResourceType.connectionRepertoire:
        return 'Repertório de Conexão';
      case ResourceType.multimediaAsset:
        return 'Asset Multimídia';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _ResourceCard extends StatelessWidget {
  final CreativeResource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ResourceCard({
    required this.resource,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    resource.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (resource.isOriginal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Original',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (resource.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                resource.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (resource.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: resource.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
