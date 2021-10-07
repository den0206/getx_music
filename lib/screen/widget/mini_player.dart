import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              "title",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "artsit",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image(
                image: AssetImage('assets/cover.jpg'),
              ),
            ),
            trailing: Container(
              height: 40,
              width: 40,
              child: Center(
                child: IconButton(
                  tooltip: "Pause",
                  onPressed: () {
                    print("Pause");
                  },
                  icon: Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
