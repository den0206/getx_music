import 'dart:async';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_controller.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_screen.dart';
import 'package:getx_music/screen/main_tab/main_tab_controller.dart';
import 'package:getx_music/src/API/spotify_api.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:get/get.dart';
import 'package:spotify/spotify.dart';

class SearchController extends GetxController {
  final List<String> history = [];

  final List res = [];

  final FloatingSearchBarController controller = FloatingSearchBarController();
  Timer? _searchTimer;

  final SpotifyService _spotify = SpotifyService();

  @override
  void onClose() {
    super.onClose();
    _searchTimer?.cancel();
    controller.dispose();
  }

  void loadHistory() {
    history.add("History");
  }

  void searchQ(String q) {
    res.clear();
    _searchTimer?.cancel();

    try {
      if (controller.query.length >= 2)
        _searchTimer = Timer(
          Duration(milliseconds: 500),
          () async {
            final temp = await _spotify.searchQ(controller.query);
            if (temp.isNotEmpty) res.addAll(temp);
            controller.close();
            update();
          },
        );
    } catch (e) {
      print(e.toString());
    }
  }

  void pushDetailArtist(Artist artsit) {
    Get.to(
      () => DetailArtistScreen(),
      arguments: artsit,
      binding: DetailArtsitBinding(),
      id: MainTabController.to.currentIndex,
    );
  }

  void clearText({bool entire = true}) {
    if (entire) {
      // controller.clear();
      controller.query = "";
      controller.close();
      update();
    } else {
      if (controller.query.isNotEmpty) {
        final position = controller.query.length - 1;
        controller.query = controller.query.substring(0, position);
      } else {
        return;
      }
    }
  }

  void clearList() {
    res.clear();
    update();
  }
}
