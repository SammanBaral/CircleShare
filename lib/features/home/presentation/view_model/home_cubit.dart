import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/items/presentation/view/add_item_view.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // New navigation function to AddItemView with necessary BLoCs
  void navigateToAddItemView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemScreen(), // Use the wrapper screen
      ),
    );
  }

  // Alternative version if you're using dependency injection
  void navigateToAddItemViewWithDI(
    BuildContext context, {
    required Function() getCategoryBloc,
    required Function() getLocationBloc,
    required Function() getItemBloc,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<CategoryBloc>(
              create: (_) => getCategoryBloc()..add(LoadCategories()),
            ),
            BlocProvider<LocationBloc>(
              create: (_) => getLocationBloc()..add(LoadLocations()),
            ),
            BlocProvider<ItemBloc>(
              create: (_) => getItemBloc(),
            ),
          ],
          child: const AddItemView(),
        ),
      ),
    );
  }
}
