import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/plant.dart';
import '../../data/repositories/plant_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/responsive_page.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Plant> _plants = [];
  bool _isLoading = true;
  bool _favoritesOnly = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    final repository = context.read<PlantRepository>();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
    final plants = await repository.getPlants(
      query: _searchController.text,
      favoritesOnly: _favoritesOnly,
    );

    if (!mounted) return;

    setState(() {
      _plants = plants;
      _isLoading = false;
      _errorMessage = null;
    });
    } catch (error, stackTrace) {
      debugPrint('Failed to load plants: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _plants = [];
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _toggleFavorite(Plant plant) async {
    await context.read<PlantRepository>().toggleFavorite(plant);
    await _loadPlants();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          plant.isFavorite
              ? '${plant.name} removed from favorites.'
              : '${plant.name} added to favorites.',
        ),
      ),
    );
  }

  Future<void> _deletePlant(Plant plant) async {
    if (plant.id == null) return;

    setState(() {
      _plants.removeWhere((item) => item.id == plant.id);
    });

    await context.read<PlantRepository>().deletePlant(plant.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plant.name} deleted.')),
    );
  }

  Future<bool> _confirmDelete(Plant plant) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete plant?'),
          content: Text('Are you sure you want to delete ${plant.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

 Future<void> _showPlantForm({Plant? plant}) async {
    final isEditing = plant != null;

    // 1. Open the form sheet widget
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _PlantFormBottomSheet(plant: plant),
    );

    // 2. This code runs ONLY after the sheet has completely closed its animation
    if (!mounted) return;
    await _loadPlants();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Plant updated.' : 'Plant added.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        actions: [
          IconButton(
            tooltip: _favoritesOnly ? 'Show all plants' : 'Show favorites only',
            onPressed: () {
              setState(() {
                _favoritesOnly = !_favoritesOnly;
              });
              _loadPlants();
            },
            icon: Icon(
              _favoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ResponsivePage(
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadPlants(),
              decoration: InputDecoration(
                labelText: 'Search plants',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _loadPlants();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPlants,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlantForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add plant'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        key: const ValueKey('plant-error'),
        child: Card(
          child: Padding (
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.danger,
                ),

                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Could not load plants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _loadPlants,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_plants.isEmpty) {
      return const EmptyState(
        key: ValueKey('empty'),
        icon: Icons.local_florist_outlined,
        title: 'No plants found',
        message: 'Add your first plant or adjust your search filters.',
      );
    }

    return ListView.separated(
      key: const ValueKey('list'),
      itemCount: _plants.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final plant = _plants[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1),
          duration: Duration(milliseconds: 180 + index * 35),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Dismissible(
            key: ValueKey('plant-${plant.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDelete(plant),
            onDismissed: (_) => _deletePlant(plant),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                leading: CircleAvatar(
                  child: Text(plant.name.characters.first.toUpperCase()),
                ),
                title: Text(plant.name),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '${plant.species}\nNext watering: ${plant.nextWateringLabel}',
                  ),
                ),
                isThreeLine: true,
                onTap: () => _showPlantForm(plant: plant),
                trailing: Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    IconButton(
                      tooltip: 'Edit plant',
                      onPressed: () => _showPlantForm(plant: plant),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Favorite',
                      onPressed: () => _toggleFavorite(plant),
                      icon: Icon(
                        plant.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: plant.isFavorite ? AppColors.danger : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlantFormBottomSheet extends StatefulWidget {
  final Plant? plant;
  const _PlantFormBottomSheet({super.key, this.plant});

  @override
  State<_PlantFormBottomSheet> createState() => _PlantFormBottomSheetState();
}

class _PlantFormBottomSheetState extends State<_PlantFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _notesController;
  late final TextEditingController _intervalController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _speciesController = TextEditingController(text: widget.plant?.species ?? '');
    _notesController = TextEditingController(text: widget.plant?.notes ?? '');
    _intervalController = TextEditingController(
      text: (widget.plant?.wateringIntervalDays ?? 7).toString(),
    );
  }

  @override
  void dispose() {
    // These now safely fire AFTER the close animation finishes entirely
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<PlantRepository>();
    final isEditing = widget.plant != null;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit plant' : 'Add plant',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plant name',
                      prefixIcon: Icon(Icons.local_florist),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Plant name is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      prefixIcon: Icon(Icons.eco),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Species is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Watering interval in days',
                      prefixIcon: Icon(Icons.water_drop),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 1) {
                        return 'Enter a number greater than 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Care notes',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final now = DateTime.now();
                        final savedPlant = Plant(
                          id: widget.plant?.id,
                          name: _nameController.text.trim(),
                          species: _speciesController.text.trim(),
                          notes: _notesController.text.trim(),
                          wateringIntervalDays: int.parse(_intervalController.text.trim()),
                          lastWateredAt: widget.plant?.lastWateredAt ?? now,
                          isFavorite: widget.plant?.isFavorite ?? false,
                          createdAt: widget.plant?.createdAt ?? now,
                          updatedAt: now,
                        );

                        if (isEditing) {
                          await repository.updatePlant(savedPlant);
                        } else {
                          await repository.addPlant(savedPlant);
                        }

                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Save changes' : 'Add plant'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}