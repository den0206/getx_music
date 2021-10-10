import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_music/screen/mini_player/mini_player_controller.dart';

class MiniPlayer extends GetView<MiniPlayerController> {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetX<MiniPlayerController>(
        init: MiniPlayerController(),
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
              ),
              PlayerSlider(),
              ListTile(
                title: Text(
                  controller.currentMediaItem.value != null
                      ? controller.currentMediaItem.value!.title
                      : "title",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  controller.currentMediaItem.value != null
                      ? controller.currentMediaItem.value!.artist ?? ""
                      : "artist",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: controller.currentMediaItem.value != null &&
                          controller.currentMediaItem.value?.artUri != null
                      ? Image.network(
                          controller.currentMediaItem.value!.artUri!.toString())
                      : Image(
                          image: AssetImage('assets/cover.jpg'),
                        ),
                ),
                trailing: ControlButtons(),
              )
            ],
          );
        },
      ),
    );
  }
}

class ControlButtons extends GetView<MiniPlayerController> {
  const ControlButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      child: Center(
        child: GetX<MiniPlayerController>(
          builder: (_) {
            if (controller.currentMediaItem.value == null) {
              return Container();
            }
            return controller.isLoading
                ? CircularProgressIndicator()
                : IconButton(
                    tooltip: "Pause",
                    onPressed: () {
                      controller.tapControl();
                    },
                    icon: controller.isPlaying
                        ? Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                  );
          },
        ),
      ),
    );
  }
}

class PlayerSlider extends GetView<MiniPlayerController> {
  const PlayerSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !controller.hasSoundSource
          ? Container()
          : SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).colorScheme.secondary,
                inactiveTrackColor: Colors.transparent,
                trackHeight: 1,
                thumbColor: Theme.of(context).colorScheme.secondary,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 1.0),
                overlayColor: Colors.transparent,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 2.0),
              ),
              child: Slider(
                inactiveColor: Colors.transparent,
                value: controller.currentPosition.value.inSeconds.toDouble(),
                max: controller.currentMediaItem.value!.duration!.inSeconds
                    .toDouble(),
                onChanged: (newposition) {
                  controller.seek(Duration(seconds: newposition.round()));
                },
                onChangeEnd: (newposition) {
                  controller.seek(Duration(seconds: newposition.round()));
                },
              ),
            ),
    );
  }
}
