import 'package:flutter/material.dart';

class OriginCrousel extends StatefulWidget {
  OriginCrousel({
    Key? key,
    required this.itemCount,
    required this.onChange,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _OriginCrouselState createState() => _OriginCrouselState();

  final int itemCount;

  final Function(int index) onChange;
  final Widget Function(BuildContext context, int index) itemBuilder;
}

class _OriginCrouselState extends State<OriginCrousel> {
  final PageController controller =
      PageController(initialPage: 0, viewportFraction: 0.6);
  late int currentPage;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentPage = controller.initialPage;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.itemCount,
      controller: controller,
      onPageChanged: (index) {
        setState(() {
          currentPage = index;
        });
        widget.onChange(index);
      },
      itemBuilder: widget.itemBuilder,
    );
  }
}
