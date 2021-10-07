import 'package:flutter/material.dart';

class MiniSpotifyImage extends StatelessWidget {
  const MiniSpotifyImage({
    Key? key,
    this.imageUrl,
  }) : super(key: key);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image(
            image: AssetImage('assets/cover.jpg'),
          ),
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return Image(
                  image: AssetImage('assets/cover.jpg'),
                );
              },
            )
        ],
      ),
    );
  }
}
