import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_state.dart';

/// Cubit for app-wide state
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  /// Initialize app
  Future<void> init() async {
    emit(state.copyWith(status: AppStatus.loading));

    try {
      // Simulate loading
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: AppStatus.ready,
        isFirstLaunch: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStatus.error,
        error: 'Failed to initialize app',
      ));
    }
  }

  /// Set first launch complete
  void setFirstLaunchComplete() {
    emit(state.copyWith(isFirstLaunch: false));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
