import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: state.selectedIndex == 0
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.explore,
                  color: state.selectedIndex == 1
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.chat,
                  color: state.selectedIndex == 2
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: state.selectedIndex == 3
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
