import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_music/main.dart';
import 'package:getx_music/screen/detail_artist/detail_artist_controller.dart';
import 'package:getx_music/screen/search/search_controller.dart';
import 'package:getx_music/screen/widget/mini_spotify_image.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spotify/spotify.dart' as sp;

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/SearchScreen';

  @override
  Widget build(BuildContext context) {
    final searchBarHeight = 52.0;
    return Theme(
      data: initialTheme(context: context).copyWith(
        iconTheme: IconThemeData(color: Colors.black),
      ),
      child: GetBuilder<SearchController>(
        init: SearchController(),
        builder: (_) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: FloatingSearchBar(
                  backgroundColor: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                  queryStyle: TextStyle(color: Colors.black87),
                  controller: controller.controller,
                  hint: 'Search Songs,',
                  height: searchBarHeight,
                  margins: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 15.0),
                  scrollPadding: const EdgeInsets.only(bottom: 50),
                  backdropColor: Colors.black45,
                  transitionCurve: Curves.easeInOut,
                  physics: const BouncingScrollPhysics(),
                  openAxisAlignment: 0.0,
                  clearQueryOnClose: false,
                  debounceDelay: const Duration(milliseconds: 500),
                  automaticallyImplyBackButton: false,
                  automaticallyImplyDrawerHamburger: false,
                  elevation: 8,
                  insets: EdgeInsets.zero,
                  leadingActions: [
                    FloatingSearchBarAction.icon(
                      showIfOpened: true,
                      size: 20.0,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      onTap: () {
                        controller.clearText();
                      },
                    ),
                  ],
                  transition:
                      // CircularFloatingSearchBarTransition(),
                      SlideFadeFloatingSearchBarTransition(),
                  actions: [
                    FloatingSearchBarAction(
                      child: Icon(Icons.search),
                    ),
                    FloatingSearchBarAction(
                      showIfOpened: true,
                      showIfClosed: false,
                      child: CircularButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
                        onPressed: () {
                          controller.clearText(entire: false);
                        },
                      ),
                    ),
                  ],
                  onQueryChanged: controller.searchQ,
                  onFocusChanged: (isFocused) {
                    if (isFocused) controller.clearList();
                  },
                  builder: (context, transition) {
                    return ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      shrinkWrap: true,
                      itemCount: controller.predicts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final current = controller.predicts[index];

                        return Slidable(
                          key: Key(current),
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: [
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.close,
                              onTap: () {
                                controller.deletePredict(index);
                              },
                            ),
                          ],
                          child: ListTile(
                            title: Text(current),
                            onTap: () {
                              controller.addRes(current);
                            },
                          ),
                        );
                      },
                    );
                  },
                  body: controller.controller.isClosed && controller.res.isEmpty
                      ? Center(
                          child: Text("No Result"),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                              10, searchBarHeight + 20, 10, 0),
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: controller.res.length,
                          itemBuilder: (context, index) {
                            final current = controller.res[index];

                            return ArtistTile(current: current);
                          },
                        ),
                ),
              ));
        },
      ),
    );
  }
}

class ArtistTile extends GetView<SearchController> {
  const ArtistTile({
    Key? key,
    required this.current,
  }) : super(key: key);

  final current;

  @override
  Widget build(BuildContext context) {
    if (current is sp.Artist) {
      return ListTile(
        leading: MiniSpotifyImage(
          imageUrl: convertImageUrl(current.images),
        ),
        title: Text(
          current.name ?? "",
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          controller.pushDetailArtist(current);
        },
      );
    }

    if (current is sp.Track) {
      current as sp.Track;

      return ListTile(
        title: Text(""),
      );
    }

    return Container();
  }
}
