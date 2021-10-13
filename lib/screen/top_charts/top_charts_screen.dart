import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_music/screen/top_charts/top_chart_controller.dart';

class TopChartsScreen extends GetView<TopChartsController> {
  const TopChartsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GetBuilder<TopChartsController>(
        init: TopChartsController(),
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Top Charts",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              bottom: TabBar(
                onTap: controller.changeIndex,
                tabs: [
                  Tab(
                    child: Text(
                      'Japan',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Global',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(children: [
              ChartPage(
                region: RegionType.japan,
              ),
              ChartPage(
                region: RegionType.global,
              )
            ]),
          );
        },
      ),
    );
  }
}

class ChartPage extends GetView<TopChartsController> {
  const ChartPage({
    Key? key,
    required this.region,
  }) : super(key: key);

  final RegionType region;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: controller.currentList.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.width / 7,
                    width: MediaQuery.of(context).size.width / 7,
                    child: const CircularProgressIndicator()),
              ],
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.currentList.length,
              itemBuilder: (context, index) {
                final item = controller.currentList[index];
                return ListTile(
                  leading: Card(
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
                        if (item["image"] != "")
                          Image.network(
                            item["image"].toString(),
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
                  ),
                  title: Text(
                    item["position"] == null
                        ? item["title"]
                        : "${item["position"]}. ${item["title"]}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item['artist']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    final id = item["id"];
                    controller.selectTrack(id);
                  },
                );
              },
            ),
    );
  }
}
