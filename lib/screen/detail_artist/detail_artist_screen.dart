import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_music/screen/widget/mini_spotify_image.dart';
import 'package:sizer/sizer.dart';

import 'package:getx_music/screen/detail_artist/detail_artist_controller.dart';

class DetailArtistScreen extends GetView<DetailArtistController> {
  const DetailArtistScreen({Key? key}) : super(key: key);

  static const routeName = '/DetailArtist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.artist.name!),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 10.h,
                backgroundImage: AssetImage('assets/cover.jpg'),
                foregroundImage: controller.artstImage != null
                    ? NetworkImage(controller.artstImage!)
                    : null,
              ),
            ],
          ),
          Divider(),
          Obx(
            () => Expanded(
                child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: controller.tracks.length,
              itemBuilder: (context, index) {
                final track = controller.tracks[index];

                return ListTile(
                  leading: MiniSpotifyImage(
                    imageUrl: convertImageUrl(track.album?.images),
                  ),
                  title: Text(track.name!),
                  onTap: () {
                    controller.selectTrack(track);
                  },
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
