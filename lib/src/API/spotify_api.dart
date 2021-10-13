import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart';
import 'package:spotify/spotify.dart';

class SpotifyService extends GetxService {
  static final credential = SpotifyApiCredentials(
    FlutterConfig.get("CLIENT_ID"),
    FlutterConfig.get("CLIENT_SECRET_ID"),
  );

  final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  final api = SpotifyApi(credential);

  @override
  void onInit() {
    super.onInit();

    final _grant = SpotifyApi.authorizationCodeGrant(credential);
    final _redirectUri = 'https://example.com/auth';
    final _authUri =
        _grant.getAuthorizationUrl(Uri.parse(_redirectUri), scopes: _scopes);
  }

  Future<List> getTopChart(String region) async {
    final lower = region.toLowerCase();
    print(lower);
    final HtmlUnescape unescape = HtmlUnescape();
    final String authority = 'www.spotifycharts.com';
    final String unencodedPath = '/regional/$lower/daily/latest/';

    final Response res = await get(Uri.https(authority, unencodedPath));

    if (res.statusCode != 200) return List.empty();

    final List result = RegExp(
            r'\<td class=\"chart-table-image\"\>\n[ ]*?\<a href=\"https:\/\/open\.spotify\.com\/track\/(.*?)\" target=\"_blank\"\>\n[ ]*?\<img src=\"(https:\/\/i\.scdn\.co\/image\/.*?)\"\>\n[ ]*?\<\/a\>\n[ ]*?<\/td\>\n[ ]*?<td class=\"chart-table-position\">([0-9]*?)<\/td>\n[ ]*?<td class=\"chart-table-trend\">[.|\n| ]*<.*\n[ ]*<.*\n[ ]*<.*\n[ ]*<.*\n[ ]*<td class=\"chart-table-track\">\n[ ]*?<strong>(.*?)<\/strong>\n[ ]*?<span>by (.*?)<\/span>\n[ ]*?<\/td>\n[ ]*?<td class="chart-table-streams">(.*?)<\/td>')
        .allMatches(res.body)
        .map((m) {
      return {
        'id': m[1],
        'image': m[2],
        'position': m[3],
        'title': unescape.convert(m[4]!),
        'album': '',
        'artist': unescape.convert(m[5]!),
        'streams': m[6],
        'region': region,
      };
    }).toList();
    // print('finished expensive operation');
    return result;
  }

  Future<List> searchQ(String q) async {
    var res = [];
    var search = await api.search
        .get(
          q,
          types: [SearchType.artist, SearchType.track],
          market: "JP",
        )
        .getPage(10, 0);

    final temp = search.map((p) => p.items).toList().first?.toList();

    if (temp != null && temp.isNotEmpty) res.addAll(temp);

    return res;
  }

  Future<Track> getTrack(String id) async {
    var track = await api.tracks.get(id);
    return track;
  }

  Future<List<Track>> getTopTracks(String id) async {
    final List<Track> tracks = [];

    var temp = await api.artists.getTopTracks(id, "jp");

    if (temp.isNotEmpty) tracks.addAll(temp);

    return tracks;
  }
}
