import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart';
import '../../application/category_notifier.dart';
import '../../../../../../shared_libs/lib/models/category.dart';


class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryNotifierProvider);

    ref.listen<CategoryState>(categoryNotifierProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCategoryDialog(context, ref: ref),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    // You can implement filtering here if needed
                  },
                ),
              ),
              Expanded(
                child: categoryState.categories.isEmpty &&
                        !categoryState.isLoading
                    ? const Center(child: Text('No categories found.'))
                    : ListView.builder(
                        itemCount: categoryState.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryState.categories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(category.name),
                              subtitle: category.description != null
                                  ? Text(category.description!)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showAddEditCategoryDialog(
                                      context,
                                      category: category,
                                      ref: ref,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, ref, category.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (categoryState.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(categoryNotifierProvider.notifier)
                  .deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context,
      {Category? category, required WidgetRef ref}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    Future.microtask(
        () => ref.read(categoryNotifierProvider.notifier).clearError());

    showDialog(
      context: context,
      barrierDismissible: !ref.watch(categoryNotifierProvider).isLoading,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(categoryNotifierProvider);
            final notifier = ref.read(categoryNotifierProvider.notifier);

            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add Category'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: state.errors['name'],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      onChanged: (_) => notifier.clearError(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                      onChanged: (_) => notifier.clearError(),
                    ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      state.isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text;
                            final description = descriptionController.text;
                            bool success = false;

                            if (isEditing) {
                              success = await notifier.updateCategory(
                                category.copyWith(
                                  name: name,
                                  description: description.isNotEmpty
                                      ? description
                                      : null,
                                ),
                              );
                            } else {
                              success = await notifier.addCategory(
                                Category(
                                  id: '', // ✅ تمرير ID مؤقت لتجنب الخطأ
                                  name: name,
                                  description: description.isNotEmpty
                                      ? description
                                      : null,
                                ),
                              );
                            }

                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
