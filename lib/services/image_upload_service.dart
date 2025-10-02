import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

/// Service for handling image uploads to Firebase Storage
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename
      final fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Create reference to the file location
      final ref = _storage.ref().child('profile_pictures/$fileName');

      // Upload the file
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print(
        'ImageUploadService: Profile picture uploaded successfully: $downloadUrl',
      );
      return downloadUrl;
    } catch (e) {
      print('ImageUploadService: Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Upload profile picture from bytes (for web)
  Future<String> uploadProfilePictureFromBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename
      final String uniqueFileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Create reference to the file location
      final ref = _storage.ref().child('profile_pictures/$uniqueFileName');

      // Upload the bytes directly
      final uploadTask = await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/png'),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print(
        'ImageUploadService: Profile picture uploaded successfully from bytes: $downloadUrl',
      );
      return downloadUrl;
    } catch (e) {
      print(
        'ImageUploadService: Error uploading profile picture from bytes: $e',
      );
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('ImageUploadService: Profile picture deleted successfully');
    } catch (e) {
      print('ImageUploadService: Error deleting profile picture: $e');
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Get profile picture URL for a user
  Future<String?> getProfilePictureUrl(String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures');
      final listResult = await ref.listAll();

      // Find the most recent profile picture for this user
      for (final item in listResult.items) {
        if (item.name.startsWith('profile_${userId}_')) {
          return await item.getDownloadURL();
        }
      }

      return null;
    } catch (e) {
      print('ImageUploadService: Error getting profile picture URL: $e');
      return null;
    }
  }

  /// Compress image if needed (basic implementation)
  Future<File> compressImage(File imageFile) async {
    // For now, return the original file
    // In a production app, you might want to add image compression here
    return imageFile;
  }
}
