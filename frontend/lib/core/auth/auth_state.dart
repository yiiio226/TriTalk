import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/user.dart';

part 'auth_state.freezed.dart';

/// Authentication status enum
enum AuthStatus {
  /// Initial state, not yet determined
  unknown,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,
}

/// Authentication state using Freezed for immutability
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    /// Current authentication status
    @Default(AuthStatus.unknown) AuthStatus status,

    /// Current authenticated user (null if not authenticated)
    User? user,

    /// Whether the user needs onboarding (profile not completed)
    @Default(false) bool needsOnboarding,

    /// Loading state for login operations
    @Default(false) bool isLoading,

    /// Error message if any
    String? error,
  }) = _AuthState;
}
