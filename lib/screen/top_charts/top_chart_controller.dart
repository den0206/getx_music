import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_music/screen/mini_player/mini_player_controller.dart';
import 'package:getx_music/src/API/spotify_api.dart';

enum RegionType { global, japan }

extension RegionEXT on RegionType {
  String get title {
    switch (this) {
      case RegionType.global:
        return "Global";
      case RegionType.japan:
        return "Japan";
    }
  }

  String get countrtCode {
    switch (this) {
      case RegionType.global:
        return "global";
      case RegionType.japan:
        return "jp";
    }
  }
}

class TopChartsController extends GetxController {
  RegionType currentRegion = RegionType.japan;

  final List localItem = [];
  final List globalItem = [];

  final SpotifyService _spotify = SpotifyService();
  final MiniPlayerController _audioHandler = MiniPlayerController.to;

  List get currentList {
    switch (currentRegion) {
      case RegionType.global:
        return globalItem;
      case RegionType.japan:
        return localItem;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await loadChart();
  }

  void changeIndex(int value) {
    switch (value) {
      case 0:
        currentRegion = RegionType.japan;
        break;
      case 1:
        currentRegion = RegionType.global;
        break;

      default:
        return;
    }

    loadChart();
  }

  Future loadChart() async {
    if (globalItem.isNotEmpty && localItem.isNotEmpty) {
      return;
    }

    final temp = await _spotify.getTopChart(currentRegion.countrtCode);
    print(temp.length);

    switch (this.currentRegion) {
      case RegionType.global:
        globalItem.addAll(temp);
        break;
      case RegionType.japan:
        localItem.addAll(temp);
    }

    update();
  }

  Future<void> selectTrack(String id) async {
    final track = await _spotify.getTrack(id);
    _audioHandler.addPlayList(track);
  }
}
