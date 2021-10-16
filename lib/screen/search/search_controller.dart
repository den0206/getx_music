import 'dart:async';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:getx_music/main.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_controller.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_screen.dart';
import 'package:getx_music/screen/main_tab/main_tab_controller.dart';
import 'package:getx_music/src/API/spotify_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:get/get.dart';
import 'package:spotify/spotify.dart';

class SearchController extends GetxController {
  List<String> predicts = [];

  final List res = [];

  final FloatingSearchBarController controller = FloatingSearchBarController();
  Timer? _searchTimer;

  final SpotifyService _spotify = SpotifyService();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onClose() {
    super.onClose();
    _searchTimer?.cancel();
    controller.dispose();
  }

  void loadHistory() {
    predicts =
        Hive.box(HiveConst.setting).get(HiveConst.predicts) as List<String>;
    print("add");

    print(predicts.length);
  }

  void searchQ(String q) {
    res.clear();
    _searchTimer?.cancel();

    try {
      if (controller.query.length >= 2)
        _searchTimer = Timer(
          Duration(milliseconds: 500),
          () async {
            await addRes(controller.query);
          },
        );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addRes(String q) async {
    controller.query = q;
    final temp = await _spotify.searchQ(q);
    if (temp.isNotEmpty) res.addAll(temp);
    controller.close();
    update();
  }

  void pushDetailArtist(Artist artsit) {
    addPredicts(artsit.name);
    Get.to(
      () => DetailArtistScreen(),
      arguments: artsit,
      binding: DetailArtsitBinding(),
      id: MainTabController.to.currentIndex,
    );
  }

  void addPredicts(String? name) {
    if (name == null) {
      return;
    }
    if (!predicts.contains(name)) {
      print("Add");
      if (predicts.length > 10) {
        predicts.removeAt(0);
      }
      predicts.add(name);
      Hive.box(HiveConst.setting).put(HiveConst.predicts, predicts);
    }
  }

  void deletePredict(int index) {
    predicts.removeAt(index);
    Hive.box(HiveConst.setting).put(HiveConst.predicts, predicts);
    update();
  }

  void clearText({bool entire = true}) {
    if (entire) {
      // controller.clear();

      controller.query = "";
      res.clear();
      print(predicts.length);
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
