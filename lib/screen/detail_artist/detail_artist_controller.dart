import 'package:get/get.dart';
import 'package:getx_music/screen/mini_player/mini_player_controller.dart';
import 'package:getx_music/src/API/spotify_api.dart';
import 'package:spotify/spotify.dart';

class DetailArtsitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DetailArtistController());
  }
}

class DetailArtistController extends GetxController {
  final Artist artist = Get.arguments;
  final RxList<Track> tracks = RxList<Track>();

  final MiniPlayerController _audioHandler = MiniPlayerController.to;

  String? get artstImage {
    return convertImageUrl(artist.images);
  }

  final SpotifyService _spotify = SpotifyService();

  @override
  void onInit() async {
    super.onInit();
    await loadTopOfMusic();
  }

  Future<void> loadTopOfMusic() async {
    if (artist.id == null) {
      return;
    }
    final temp = await _spotify.getTopTracks(artist.id!);
    tracks.value = temp;
    print(tracks.length);
  }

  void selectTrack(Track track) {
    _audioHandler.addPlayList(track);
  }
}

String? convertImageUrl(List<Image>? images) {
  if (images == null || images.isEmpty) return null;
  return images.first.url;
}
