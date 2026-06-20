import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/cloudinary_service.dart';
import '../models/profile_model.dart';
import '../repositories/user_repository.dart';
import 'auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

class ProfileState {
  final StudentProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    StudentProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepository _userRepository;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  ProfileNotifier(this._userRepository, String? uid) : super(ProfileState()) {
    if (uid != null) {
      loadProfile(uid);
    }
  }

  Future<void> loadProfile(String uid) async {
    state = ProfileState(isLoading: true);
    try {
      final profile = await _userRepository.getProfile(uid);
      if (profile != null) {
        // Increment daily streak if logging in on a new day
        await _userRepository.updateStreak(uid);
        final freshProfile = await _userRepository.getProfile(uid);
        state = ProfileState(profile: freshProfile);
      } else {
        // Return default empty profile if none exists
        state = ProfileState(profile: StudentProfile.empty(uid, ""));
      }
    } catch (e) {
      state = ProfileState(errorMessage: e.toString());
    }
  }

  Future<void> updateProfile(StudentProfile updatedProfile) async {
    state = state.copyWith(isLoading: true);
    try {
      await _userRepository.saveProfile(updatedProfile);
      state = ProfileState(profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> uploadProfileImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    if (state.profile == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final imageUrl = await _cloudinaryService.uploadFile(
        file: file,
        bytes: bytes,
        fileName: fileName,
        folder: "profiles",
        isImage: true,
      );
      final updatedProfile = state.profile!.copyWith(profileImageUrl: imageUrl);
      await _userRepository.saveProfile(updatedProfile);
      state = ProfileState(profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final auth = ref.watch(authProvider);
  return ProfileNotifier(userRepo, auth.uid);
});
