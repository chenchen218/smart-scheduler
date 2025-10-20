import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling comprehensive user data deletion
/// Ensures all user data is removed from Firestore, Storage, and local storage
class UserDataDeletionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Delete all user data comprehensively
  /// Returns true if successful, false otherwise
  Future<bool> deleteAllUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userId = user.uid;
      print('UserDataDeletionService: Starting deletion for user: $userId');

      // Step 1: Delete all Firestore collections
      await _deleteFirestoreCollections(userId);

      // Step 2: Delete Firebase Storage files
      await _deleteStorageFiles(userId);

      // Step 3: Clear local storage
      await _clearLocalStorage();

      // Step 4: Delete Firebase Auth user (this must be last)
      await _deleteFirebaseUser();

      print('UserDataDeletionService: All user data deleted successfully');
      return true;
    } catch (e) {
      print('UserDataDeletionService: Error deleting user data: $e');
      return false;
    }
  }

  /// Delete all Firestore collections for the user
  Future<void> _deleteFirestoreCollections(String userId) async {
    try {
      print(
        'UserDataDeletionService: Deleting Firestore collections for user: $userId',
      );

      final userDocRef = _firestore.collection('users').doc(userId);

      // Get all subcollections
      final collections = ['events', 'tasks', 'settings'];

      for (final collectionName in collections) {
        await _deleteSubcollection(userDocRef, collectionName);
      }

      // Delete the user document itself
      await userDocRef.delete();
      print(
        'UserDataDeletionService: Firestore collections deleted successfully',
      );
    } catch (e) {
      print(
        'UserDataDeletionService: Error deleting Firestore collections: $e',
      );
      rethrow;
    }
  }

  /// Delete a subcollection using batch operations
  Future<void> _deleteSubcollection(
    DocumentReference docRef,
    String collectionName,
  ) async {
    try {
      final collectionRef = docRef.collection(collectionName);
      final batch = _firestore.batch();

      // Get all documents in the subcollection
      final snapshot = await collectionRef.get();

      // Delete documents in batches of 500 (Firestore limit)
      for (int i = 0; i < snapshot.docs.length; i += 500) {
        final batchDocs = snapshot.docs.skip(i).take(500);

        for (final doc in batchDocs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        print(
          'UserDataDeletionService: Deleted batch of ${batchDocs.length} documents from $collectionName',
        );
      }
    } catch (e) {
      print(
        'UserDataDeletionService: Error deleting subcollection $collectionName: $e',
      );
      rethrow;
    }
  }

  /// Delete Firebase Storage files for the user
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      print(
        'UserDataDeletionService: Deleting Firebase Storage files for user: $userId',
      );

      // Delete profile pictures
      final profilePicsRef = _storage.ref().child('profile_pictures/$userId');

      try {
        final listResult = await profilePicsRef.listAll();

        // Delete all files in the user's profile pictures folder
        for (final item in listResult.items) {
          await item.delete();
          print('UserDataDeletionService: Deleted storage file: ${item.name}');
        }

        // Delete the folder itself if it exists
        try {
          await profilePicsRef.delete();
        } catch (e) {
          // Folder might not exist, which is fine
          print(
            'UserDataDeletionService: Profile pictures folder not found or already deleted',
          );
        }
      } catch (e) {
        print(
          'UserDataDeletionService: No storage files found for user: $userId',
        );
      }

      print(
        'UserDataDeletionService: Firebase Storage files deleted successfully',
      );
    } catch (e) {
      print('UserDataDeletionService: Error deleting storage files: $e');
      rethrow;
    }
  }

  /// Clear all local storage data
  Future<void> _clearLocalStorage() async {
    try {
      print('UserDataDeletionService: Clearing local storage');

      final prefs = await SharedPreferences.getInstance();

      // Clear all app data
      await prefs.clear();

      print('UserDataDeletionService: Local storage cleared successfully');
    } catch (e) {
      print('UserDataDeletionService: Error clearing local storage: $e');
      rethrow;
    }
  }

  /// Delete the Firebase Auth user
  Future<void> _deleteFirebaseUser() async {
    try {
      print('UserDataDeletionService: Deleting Firebase Auth user');

      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print(
          'UserDataDeletionService: Firebase Auth user deleted successfully',
        );
      }
    } catch (e) {
      print('UserDataDeletionService: Error deleting Firebase Auth user: $e');
      rethrow;
    }
  }

  /// Get estimated data count for user (for confirmation dialog)
  Future<Map<String, int>> getUserDataCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'events': 0, 'tasks': 0, 'settings': 0};
      }

      final userId = user.uid;
      final userDocRef = _firestore.collection('users').doc(userId);

      final Map<String, int> counts = {};

      // Count events
      final eventsSnapshot = await userDocRef.collection('events').get();
      counts['events'] = eventsSnapshot.docs.length;

      // Count tasks
      final tasksSnapshot = await userDocRef.collection('tasks').get();
      counts['tasks'] = tasksSnapshot.docs.length;

      // Count settings
      final settingsSnapshot = await userDocRef.collection('settings').get();
      counts['settings'] = settingsSnapshot.docs.length;

      return counts;
    } catch (e) {
      print('UserDataDeletionService: Error getting user data count: $e');
      return {'events': 0, 'tasks': 0, 'settings': 0};
    }
  }
}
