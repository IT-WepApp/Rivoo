import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart';
import '../../../../../../shared_libs/lib/widgets/widgets .dart';
import '../../application/profile_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    ref.listen<AsyncValue<DeliveryPersonModel?>>(profileProvider,
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
      appBar: AppBar(title: const Text("Profile")),
      body: profileState.when(
        data: (profileData) {
          if (profileData == null) {
            return const Center(child: Text('Profile data not found.'));
          }
          return _ProfileContent(profile: profileData);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load profile: $error')),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final DeliveryPersonModel profile;

  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = widget.profile.name;
      }
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text,
    );

    final success =
        await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'), backgroundColor: Colors.green),
      );
      _toggleEditing();
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileUpdateState = ref.watch(profileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                widget.profile.name.isNotEmpty
                    ? widget.profile.name[0].toUpperCase()
                    : '?',
                style: theme.textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 16),

            // الإيميل
            Text(widget.profile.email ?? 'No Email',
                style: theme.textTheme.titleMedium),

            // 🚗 معلومات المركبة
            if (widget.profile.vehicleDetails != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Vehicle: ${widget.profile.vehicleDetails}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

            // 📍 إحداثيات الموقع
            if (widget.profile.currentLat != null &&
                widget.profile.currentLng != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Location: (${widget.profile.currentLat}, ${widget.profile.currentLng})',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ),

            const SizedBox(height: 24),

            // Editable field
            AppTextField(
              controller: _nameController,
              label: 'Name',
              enabled: _isEditing,
              validator: (value) => value == null || value.isEmpty
                  ? 'Name cannot be empty'
                  : null,
            ),
            const SizedBox(height: 24),

            // Action buttons
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: profileUpdateState is AsyncLoading
                        ? null
                        : _toggleEditing,
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: profileUpdateState is AsyncLoading
                        ? null
                        : _updateProfile,
                    child: profileUpdateState is AsyncLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              )
            else
              AppButton(
                text: 'Edit Profile',
                onPressed: _toggleEditing,
              ),
          ],
        ),
      ),
    );
  }
}
