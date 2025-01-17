import 'package:bloc/bloc.dart';

class HomeState {
  final int selectedIndex;
  final bool isCommunityUpdateVisible;

  HomeState({
    required this.selectedIndex,
    required this.isCommunityUpdateVisible,
  });

  HomeState copyWith({
    int? selectedIndex,
    bool? isCommunityUpdateVisible,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCommunityUpdateVisible:
          isCommunityUpdateVisible ?? this.isCommunityUpdateVisible,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit()
      : super(
          HomeState(
            selectedIndex: 0,
            isCommunityUpdateVisible: true,
          ),
        );

  void setSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  void toggleCommunityUpdateVisibility() {
    emit(state.copyWith(
        isCommunityUpdateVisible: !state.isCommunityUpdateVisible));
  }
}
