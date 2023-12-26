import 'package:flutter/material.dart';
import 'package:safehome/home/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/place_holders.dart';

class HomePageNoInternet extends StatelessWidget {
  const HomePageNoInternet({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 55,
        child: const HomeGuardAppBar(),
      ),
      body: Center(
          child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: height / 17,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height / 17,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: height / 17,
                    width: width / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height / 17,
                    width: width / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height / 17,
                    width: width / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height / 17,
                    width: width / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height / 17,
                    width: width / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const ListPlaceHolder(count: 6, width: 1, space: 10),
          ],
        ),
      )),
    );
  }
}

shimmerContainerBox(height, width, count, double vertical, containerWidth,
    [containerHeight = 13]) {
  List<Widget> boxes = [];
  for (var i = 0; i < count; i++) {
    boxes.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: vertical),
        child: Container(
          height: height / containerHeight,
          width: width / containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  return Center(
      child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          enabled: true,
          child: Column(
            children: boxes,
          )));
}
