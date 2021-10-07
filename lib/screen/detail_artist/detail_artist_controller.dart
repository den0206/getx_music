import 'package:get/get.dart';
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
}

String? convertImageUrl(List<Image>? images) {
  if (images == null || images.isEmpty) return null;
  return images.first.url;
}
