import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/models/models.dart';
import '../../application/profile_notifier.dart';
// Needed for AppTextField

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    final initialProfileState = ref.read(profileProvider);
    initialProfileState.whenData((profile) {
      if (profile != null) {
        _updateControllers(profile);
      }
    });
  }

  void _updateControllers(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(profileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile != null && mounted) {
          _updateControllers(profile);
        }
      });
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${next.error}"),
              backgroundColor: Colors.red),
        );
      }
    });

    final profileState = ref.watch(profileProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryColor,
        actions: [
          if (profileState is AsyncData && profileState.value != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_isEditing) {
                        if (_formKey.currentState!.validate()) {
                          _saveProfile(profileState.value!);
                        }
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
            ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
                child: Text('Please log in to view your profile.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: _buildProfileForm(profile),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading profile: $err'),
            ElevatedButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).fetchProfile(),
                child: const Text('Retry'))
          ],
        )),
      ),
    );
  }

  Widget _buildProfileForm(UserModel profile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            readOnly: !_isEditing,
            decoration: InputDecoration(
              labelText: 'Name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: _isEditing
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: Colors.grey.shade200,
              filled: true,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (_isSaving) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _saveProfile(UserModel currentProfile) async {
    setState(() => _isSaving = true);
    final profileNotifier = ref.read(profileProvider.notifier);

    final updatedUser = currentProfile.copyWith(
      name: _nameController.text,
    );

    await profileNotifier.updateProfile(updatedUser);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }
}
