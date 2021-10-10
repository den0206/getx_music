import 'package:audio_service/audio_service.dart';

import 'package:just_audio/just_audio.dart';

class AudioPlayerHandlerImpl extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayerHandlerImpl() {
    _loadEmptyPlayList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();

    _listenForCurrentSongIndexChanges();
    // _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlayList() async {
    try {
      await _player.setAudioSource(_playlist);
      _player.setVolume(1);
    } catch (e) {
      print(e.toString());
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              MediaControl.skipToNext,
            ],
            systemActions: const {
              MediaAction.seek,
            },
            androidCompactActionIndices: const [
              0,
              1,
              3
            ],
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
            shuffleMode: (_player.shuffleModeEnabled)
                ? AudioServiceShuffleMode.all
                : AudioServiceShuffleMode.none),
      );
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;

      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playList = queue.value;
      print(index);
      if (index == null || playList.isEmpty) return;

      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }

      print("current Track is ${playList[index]}");
      mediaItem.add(playList[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
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

  /// override

  @override
  Future<void> addQueueItem(MediaItem media) async {
    await _playlist.add(_itemToSource(media));

    final newQueue = queue.value..add(media);
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    _playlist.removeAt(index);

    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
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

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<void> stop() async {
    await _player.dispose();
    return super.stop();
  }

  Future<void> setTrack(MediaItem media) async {
    mediaItem.add(media);
    if (_player.playing) {
      await _player.pause();
    }
    await _player.setAudioSource(_itemToSource(media), preload: false);
    await _player.load();
    await _player.play();
  }
}
