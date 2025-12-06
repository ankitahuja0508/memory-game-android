import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void setInitialized() {
    emit(state.copyWith(isInitialized: true));
  }

  void setFirstLaunchComplete() {
    emit(state.copyWith(isFirstLaunch: false));
  }
}
