import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandlerImpl extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayerHandlerImpl() {
    _loadEmptyPlayList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
  }

  Future<void> _loadEmptyPlayList() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print(e.toString());
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    final audioSource = AudioSource.uri(
        mediaItem.artUri.toString().startsWith('file:')
            ? Uri.file(mediaItem.extras!['url'].toString())
            : Uri.parse(mediaItem.extras!['url'].toString()));

    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) =>
      mediaItems.map(_itemToSource).toList();

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> play() async {
    playbackState.add(
      playbackState.value
          .copyWith(playing: true, controls: [MediaControl.pause]),
    );
    await _player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [MediaControl.play],
      ),
    );
    await _player.play();
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}

class MyAudionHandler extends GetxService {
  static MyAudionHandler get to => Get.find();

  late AudioPlayerHandlerImpl audioHandler;

  @override
  void onInit() async {
    super.onInit();

    await startService();
    print(audioHandler);
    print("INIT AUDIO");
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

  void _listenToPlaybackState() {
    audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {}
    });
  }

  void play() => audioHandler.play();

  void pause() => audioHandler.pause();
  void seek(Duration position) => audioHandler.seek(position);
}
