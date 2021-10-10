import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_controller.dart';
import 'package:getx_music/service/my_audio_handler.dart';
import 'package:spotify/spotify.dart';

class MiniPlayerController extends GetxController {
  static MiniPlayerController get to => Get.find();

  late AudioPlayerHandlerImpl audioHandler;

  final Rxn<MediaItem> currentMediaItem = Rxn<MediaItem>();
  final Rx<PlaybackState> currentPlayBack = PlaybackState().obs;
  final Rx<Duration> currentPosition = Duration().obs;
  final RxBool isShuffle = false.obs;

  get isPlaying {
    return currentPlayBack.value.playing;
  }

  get isLoading {
    return (currentPlayBack.value.processingState ==
            AudioProcessingState.loading) ||
        (currentPlayBack.value.processingState ==
            AudioProcessingState.buffering);
  }

  get hasSoundSource {
    return (currentMediaItem.value != null) &&
        (currentMediaItem.value!.duration != null);
  }

  @override
  void onInit() async {
    super.onInit();

    await startService();

    _bindPlayerStream();
  }

  @override
  void onClose() {
    super.onClose();
    audioHandler.stop();
  }

  Future<void> startService() async {
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.shadow.getmusic.channel.audio',
        androidNotificationChannelName: 'GetMusic',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'drawable/ic_stat_music_note',
        androidShowNotificationBadge: true,
        // androidStopForegroundOnPause: Hive.box('settings')
        // .get('stopServiceOnPause', defaultValue: true) as bool,
        notificationColor: Colors.grey[900],
      ),
    );
  }

  void _bindPlayerStream() {
    /// current media
    currentMediaItem.bindStream(audioHandler.mediaItem);
    ever(currentMediaItem, (MediaItem? media) {
      print(media?.title);
    });

    /// playbackState
    currentPlayBack.bindStream(audioHandler.playbackState);
    ever(currentPlayBack, (PlaybackState state) {});

    /// position
    currentPosition.bindStream(AudioService.position);
    ever(currentPosition, (Duration position) {});
  }

  void shuffle() {
    final enable = !isShuffle.value;
    isShuffle.call(enable);
    if (enable) {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void play() => audioHandler.play();

  void pause() => audioHandler.pause();

  void seek(Duration position) => audioHandler.seek(position);

  void previous() => audioHandler.skipToPrevious();

  void next() => audioHandler.skipToNext();

  Future<void> addPlayList(Track track) async {
    Uri? artUri;
    final artString = convertImageUrl(track.album?.images);
    if (artString != null) {
      artUri = Uri.parse(artString);
    }
    final MediaItem mediaItem = MediaItem(
      id: track.id ?? "",
      title: track.name ?? "",
      album: track.album?.name ?? null,
      artist: track.artists?.first.name ?? null,
      artUri: artUri,
      duration: track.duration ?? null,
      extras: {"url": track.previewUrl},
    );

    print(mediaItem);
    await audioHandler.setTrack(mediaItem);
  }

  void remove() {
    final lastIndex = audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    audioHandler.removeQueueItemAt(lastIndex);
  }

  void tapControl() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }
}
