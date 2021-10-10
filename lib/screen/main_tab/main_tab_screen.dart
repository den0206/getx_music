import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_music/screen/main_tab/main_tab_controller.dart';
import 'package:getx_music/screen/mini_player/mini_player.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainTabScreen extends GetView<MainTabController> {
  const MainTabScreen({Key? key}) : super(key: key);

  static const routeName = '/MainTab';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainTabController>(
      init: MainTabController(),
      builder: (_) {
        return Scaffold(
          body: IndexedStack(
            children: controller.menuPages,
            index: controller.currentIndex,
          ),
          bottomNavigationBar: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MiniPlayer(),
                SalomonBottomBar(
                  currentIndex: controller.currentIndex,
                  onTap: controller.onTap,
                  items: controller.items,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
