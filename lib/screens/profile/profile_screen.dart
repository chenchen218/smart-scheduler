import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/image_upload_service.dart';
import '../../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user),
                const SizedBox(height: 32),

                // Profile Information
                _buildProfileInfo(context, user),
                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(context, authProvider),
                const SizedBox(height: 32),

                // Sign Out Button
                _buildSignOutButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture with Edit Button
          Stack(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  print(
                    'ProfileScreen: Building CircleAvatar with photoURL: ${user.photoURL}',
                  );
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: user.photoURL != null && user.photoURL!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildInitialsAvatar(context, user);
                              },
                            ),
                          )
                        : _buildInitialsAvatar(context, user),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerDialog(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Name
          Text(
            user.displayName ?? 'User',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            user.email,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
      ),
      child: Center(
        child: Text(
          user.displayName?.isNotEmpty == true
              ? user.displayName![0].toUpperCase()
              : user.email[0].toUpperCase(),
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Display Name',
            subtitle: user.displayName ?? 'Not set',
            trailing: Icon(
              Icons.edit_outlined,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            onTap: () => _showEditNameDialog(context, user),
          ),
          _buildDivider(context),
          _buildInfoTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user.email,
            trailing: Icon(
              user.isEmailVerified
                  ? Icons.verified_rounded
                  : Icons.warning_amber_rounded,
              size: 18,
              color: user.isEmailVerified
                  ? colorScheme.secondary
                  : colorScheme.error,
            ),
          ),
          _buildDivider(context),
          _buildInfoTile(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Member Since',
            subtitle: _formatDate(user.createdAt),
            trailing: null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 0.5,
      color: colorScheme.outline.withOpacity(0.2),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Settings',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                trailing: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.toggleNotifications();
                  },
                ),
              );
            },
          ),
          _buildDivider(context),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return _buildSettingsTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                trailing: Switch(
                  value: settingsProvider.darkModeEnabled,
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode();
                  },
                ),
              );
            },
          ),
          _buildDivider(context),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Change Password',
            subtitle: 'Update your account password',
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthProvider authProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showSignOutDialog(context, authProvider),
        icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
        label: Text(
          'Sign Out',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, user) {
    final nameController = TextEditingController(text: user.displayName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your display name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.state.isLoading
                    ? null
                    : () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name cannot be empty'),
                            ),
                          );
                          return;
                        }

                        final success = await authProvider.updateUserProfile(
                          displayName: newName,
                        );

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name updated successfully'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update name: ${authProvider.state.error}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: authProvider.state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your current password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter your new password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                hintText: 'Confirm your new password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.state.isLoading
                    ? null
                    : () async {
                        final currentPassword = currentPasswordController.text
                            .trim();
                        final newPassword = newPasswordController.text.trim();
                        final confirmPassword = confirmPasswordController.text
                            .trim();

                        if (currentPassword.isEmpty ||
                            newPassword.isEmpty ||
                            confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All fields are required'),
                            ),
                          );
                          return;
                        }

                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('New passwords do not match'),
                            ),
                          );
                          return;
                        }

                        if (newPassword.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password must be at least 6 characters',
                              ),
                            ),
                          );
                          return;
                        }

                        final success = await authProvider.updatePassword(
                          newPassword,
                        );

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update password: ${authProvider.state.error}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: authProvider.state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showImagePickerDialog(BuildContext context) {
    print('ProfileScreen: Showing image picker dialog...');

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Picture',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    print('ProfileScreen: Camera option selected');
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                _buildImagePickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    print('ProfileScreen: Gallery option selected');
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final canRemove = authProvider.user?.photoURL != null;
                    print('ProfileScreen: Remove option available: $canRemove');
                    return _buildImagePickerOption(
                      context,
                      icon: Icons.delete,
                      label: 'Remove',
                      onTap: canRemove
                          ? () {
                              print('ProfileScreen: Remove option selected');
                              Navigator.pop(context);
                              _removeProfilePicture(context);
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: onTap != null
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: onTap != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onTap != null
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    print('ProfileScreen: Starting image picker...');
    print('ProfileScreen: Image source: $source');

    try {
      final ImagePicker picker = ImagePicker();
      print(
        'ProfileScreen: Picking image with max dimensions 512x512, quality 85%...',
      );

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        print('ProfileScreen: Image selected successfully!');
        print('ProfileScreen: Image path: ${image.path}');
        print('ProfileScreen: Image name: ${image.name}');
        print('ProfileScreen: Image size: ${await image.length()} bytes');

        // Handle web blob URLs differently
        if (image.path.startsWith('blob:')) {
          print('ProfileScreen: Web blob URL detected, reading bytes...');
          final bytes = await image.readAsBytes();
          print('ProfileScreen: Read ${bytes.length} bytes from blob');

          // For web, upload bytes directly without creating a file
          // Use global navigator key for stable context access
          final globalContext = MiniTodoApp.navigatorKey.currentContext;
          if (globalContext != null) {
            _uploadProfilePictureFromBytes(globalContext, bytes, image.name);
          } else {
            print(
              'ProfileScreen: Global context not available, aborting upload',
            );
          }
        } else {
          print('ProfileScreen: Regular file path, creating File object...');
          final imageFile = File(image.path);
          print('ProfileScreen: File exists: ${await imageFile.exists()}');
          print('ProfileScreen: File size: ${await imageFile.length()} bytes');

          await _uploadProfilePicture(context, imageFile);
        }
      } else {
        print('ProfileScreen: No image selected (user cancelled)');
      }
    } catch (e) {
      print('ProfileScreen: Error in image picker: $e');
      print('ProfileScreen: Error type: ${e.runtimeType}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePictureFromBytes(
    BuildContext context,
    List<int> bytes,
    String fileName,
  ) async {
    print('ProfileScreen: Starting profile picture upload from bytes...');
    print('ProfileScreen: Bytes length: ${bytes.length}');
    print('ProfileScreen: File name: $fileName');
    print('ProfileScreen: Context mounted: ${context.mounted}');

    if (!context.mounted) {
      print('ProfileScreen: Context is not mounted, aborting upload');
      return;
    }

    try {
      // Show loading dialog
      print('ProfileScreen: Showing loading dialog...');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      print('ProfileScreen: Creating ImageUploadService...');
      final ImageUploadService uploadService = ImageUploadService();

      print('ProfileScreen: Starting Firebase upload from bytes...');
      final String imageUrl = await uploadService.uploadProfilePictureFromBytes(
        bytes,
        fileName,
      );
      print('ProfileScreen: Firebase upload completed. URL: $imageUrl');

      // Check context before proceeding
      if (!context.mounted) {
        print('ProfileScreen: Context not mounted after upload, aborting');
        return;
      }

      // Update user profile with new photo URL
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print(
        'ProfileScreen: Current user before update: ${authProvider.user?.email}',
      );
      print(
        'ProfileScreen: Current photoURL before update: ${authProvider.user?.photoURL}',
      );
      print('ProfileScreen: Updating user profile with photo URL: $imageUrl');

      final success = await authProvider.updateUserProfile(photoURL: imageUrl);
      print('ProfileScreen: Profile update success: $success');

      // Check the updated user data
      final updatedUser = authProvider.user;
      print('ProfileScreen: Updated user email: ${updatedUser?.email}');
      print('ProfileScreen: Updated user photoURL: ${updatedUser?.photoURL}');
      print(
        'ProfileScreen: Updated user displayName: ${updatedUser?.displayName}',
      );

      // Close loading dialog safely
      print('ProfileScreen: Closing loading dialog...');
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (success) {
        print('ProfileScreen: Upload successful, showing success message...');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('ProfileScreen: Upload failed, showing error message...');
        print('ProfileScreen: AuthProvider error: ${authProvider.state.error}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${authProvider.state.error}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('ProfileScreen: Exception during upload: $e');
      print('ProfileScreen: Exception type: ${e.runtimeType}');

      // Close loading dialog safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(
    BuildContext context,
    File imageFile,
  ) async {
    print('ProfileScreen: Starting profile picture upload...');
    print('ProfileScreen: Image file path: ${imageFile.path}');
    print('ProfileScreen: Image file size: ${await imageFile.length()} bytes');

    try {
      // Show loading dialog
      print('ProfileScreen: Showing loading dialog...');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      print('ProfileScreen: Creating ImageUploadService...');
      final ImageUploadService uploadService = ImageUploadService();

      print('ProfileScreen: Starting Firebase upload...');
      final String imageUrl = await uploadService.uploadProfilePicture(
        imageFile,
      );
      print('ProfileScreen: Firebase upload completed. URL: $imageUrl');

      // Update user profile with new photo URL
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print(
        'ProfileScreen: Current user before update: ${authProvider.user?.email}',
      );
      print(
        'ProfileScreen: Current photoURL before update: ${authProvider.user?.photoURL}',
      );
      print('ProfileScreen: Updating user profile with photo URL: $imageUrl');

      final success = await authProvider.updateUserProfile(photoURL: imageUrl);
      print('ProfileScreen: Profile update success: $success');

      // Check the updated user data
      final updatedUser = authProvider.user;
      print('ProfileScreen: Updated user email: ${updatedUser?.email}');
      print('ProfileScreen: Updated user photoURL: ${updatedUser?.photoURL}');
      print(
        'ProfileScreen: Updated user displayName: ${updatedUser?.displayName}',
      );

      // Close loading dialog safely
      print('ProfileScreen: Closing loading dialog...');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (success) {
        print('ProfileScreen: Upload successful, showing success message...');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('ProfileScreen: Upload failed, showing error message...');
        print('ProfileScreen: AuthProvider error: ${authProvider.state.error}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${authProvider.state.error}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('ProfileScreen: Exception during upload: $e');
      print('ProfileScreen: Exception type: ${e.runtimeType}');

      // Close loading dialog safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfilePicture(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user?.photoURL != null) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Delete from Firebase Storage
        final ImageUploadService uploadService = ImageUploadService();
        await uploadService.deleteProfilePicture(user!.photoURL!);

        // Update user profile to remove photo URL
        final success = await authProvider.updateUserProfile(photoURL: '');

        // Close loading dialog safely
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture removed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to remove profile picture: ${authProvider.state.error}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading dialog safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
