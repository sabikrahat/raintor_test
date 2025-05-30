import 'package:flutter/material.dart';
import 'package:raintor_test/core/config/constant.dart';
import 'package:raintor_test/core/router/go_routes.dart';

import 'enum/enum.dart';

class KBottomNavbar extends StatelessWidget {
  const KBottomNavbar({super.key, required this.selectedNavbar});

  final KNavbar selectedNavbar;

  @override
  Widget build(BuildContext context) {
    final idx = KNavbar.values.indexWhere((e) => e == selectedNavbar);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      child: BottomNavigationBar(
        backgroundColor: kPrimaryColor,
        unselectedItemColor: Colors.white38,
        selectedItemColor: Colors.white,
        currentIndex: idx,
        items: List.generate(
          KNavbar.values.length,
          (i) => kBottomNavBarItem(context, KNavbar.values[i]),
        ),
        onTap: (i) async {
          if (idx == i) return;
          await context.goPush(KNavbar.values[i].route);
        },
      ),
    );
  }

  BottomNavigationBarItem kBottomNavBarItem(BuildContext context, KNavbar data) {
    return BottomNavigationBarItem(
      label: data.title,
      activeIcon: Icon(data.iconSelected),
      icon: Icon(data.icon),
    );
  }
}
