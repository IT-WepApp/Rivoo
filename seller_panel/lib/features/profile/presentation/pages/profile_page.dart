import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart';
import '../../../../../../shared_libs/lib/widgets/widgets .dart';
import '../../application/profile_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(sellerProfileProvider);

    ref.listen<AsyncValue<SellerModel?>>(sellerProfileProvider,
        (previous, next) {
      if (next is AsyncError && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile')),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Could not load seller profile.'));
          }
          return _ProfileContent(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load profile: $error')),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final SellerModel profile;
  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  late TextEditingController _nameController;
  late TextEditingController _storeNameController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _storeNameController =
        TextEditingController(text: widget.profile.storeName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = widget.profile.name;
        _storeNameController.text = widget.profile.storeName ?? '';
        _formKey.currentState?.reset();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      storeName: _storeNameController.text.trim(),
    );

    final success = await ref
        .read(sellerProfileProvider.notifier)
        .updateProfile(updatedProfile);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully.'),
              backgroundColor: Colors.green),
        );
        _toggleEdit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile.'),
              backgroundColor: Colors.red),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                  widget.profile.name.isNotEmpty
                      ? widget.profile.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.displaySmall),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(widget.profile.email),
            ),
            const Divider(),
            AppTextField(
              controller: _nameController,
              label: 'Your Name',
              enabled: _isEditing,
              validator: (value) => value == null || value.isEmpty
                  ? 'Name cannot be empty'
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _storeNameController,
              label: 'Store Name',
              enabled: _isEditing,
              validator: (value) => value == null || value.isEmpty
                  ? 'Store name cannot be empty'
                  : null,
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    onPressed: _isSaving ? null : _toggleEdit,
                  ),
                  ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save Changes'),
                    onPressed: _isSaving ? null : _saveChanges,
                  ),
                ],
              )
            else
              AppButton(
                text: 'Edit Profile',
                onPressed: _toggleEdit,
              ),
          ],
        ),
      ),
    );
  }
}
