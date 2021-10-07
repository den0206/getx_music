import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:getx_music/screen/search/search_screen.dart';
import 'package:getx_music/screen/top_charts/top_charts_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainTabController extends GetxController {
  static MainTabController get to => Get.find();
  int currentIndex = 0;

  final List<Widget> pages = [
    SearchScreen(),
    TopChartsScreen(),
    Text("YouTube"),
    Text("Library"),
  ];

  final items = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home_rounded),
      title: const Text('Home'),
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.trending_up_rounded),
      title: const Text('Top Charts'),
    ),
    SalomonBottomBarItem(
      icon: const Icon(MdiIcons.youtube),
      title: const Text('YouTube'),
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.my_library_music_rounded),
      title: const Text('Library'),
    ),
  ];

  List<Widget> get menuPages {
    final map = pages.asMap();
    final List<_TabNav> res = [];

    map.forEach((key, value) {
      final tab = _TabNav(index: key, child: value);
      res.add(tab);
    });

    return res;
  }

  void onTap(int value) {
    currentIndex = value;
    update();
  }
}

class _TabNav extends GetView<MainTabController> {
  final int index;
  final Widget child;
  _TabNav({
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(index),
      observers: [GetObserver((_) {}, Get.routing)],
      onGenerateRoute: (settings) {
        Get.routing.args = settings.arguments;
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }
}
