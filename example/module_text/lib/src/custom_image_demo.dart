import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:module_service/module_service.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:module_widget/module_widget.dart';

@FFRoute(name: "fluttercandies://customimagetext", routeName: "CustomImageDemo")
class CustomImageTextDemo extends StatefulWidget {
  @override
  _CustomImageTextDemoState createState() => _CustomImageTextDemoState();
}

class _CustomImageTextDemoState extends State<CustomImageTextDemo> {
  TuChongRepository listSourceRepository = TuChongRepository();
  @override
  void initState() {
    listSourceRepository.refresh().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("custom inline-image in text"),
      ),
      body: listSourceRepository.isEmpty
          ? Container()
          : Container(
              padding: EdgeInsets.all(20.0),
              child: ExtendedText.rich(
                TextSpan(children: <InlineSpan>[
                  TextSpan(text: "click image show it in photo view.\n"),
                  TextSpan(text: "This is an image with placeholder."),
                  WidgetSpan(
                    child: GestureDetector(
                        onTap: () {
                          onTap(context, 0);
                        },
                        child: ExtendedImage.network(
                            listSourceRepository[0].imageUrl,
                            width: 80.0,
                            height: 80.0,
                            loadStateChanged: loadStateChanged)),
                  ),
                  TextSpan(text: "This is an image with border"),
                  WidgetSpan(
                    child: GestureDetector(
                        onTap: () {
                          onTap(context, 1);
                        },
                        child: ExtendedImage.network(
                            listSourceRepository[1].imageUrl,
                            width: 80.0,
                            height: 80.0,
                            border: Border.all(color: Colors.red, width: 1.0),
                            shape: BoxShape.rectangle,
                            loadStateChanged: loadStateChanged)),
                  ),
                  TextSpan(text: "This is an image with borderRadius"),
                  WidgetSpan(
                    child: GestureDetector(
                        onTap: () {
                          onTap(context, 2);
                        },
                        child: ExtendedImage.network(
                            listSourceRepository[2].imageUrl,
                            width: 80.0,
                            height: 60.0,
                            border: Border.all(color: Colors.red, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            shape: BoxShape.rectangle,
                            loadStateChanged: loadStateChanged)),
                  ),
                  TextSpan(text: "This is an circle image with border\n"),
                  WidgetSpan(
                    child: GestureDetector(
                        onTap: () {
                          onTap(context, 3);
                        },
                        child: ExtendedImage.network(
                            listSourceRepository[3].imageUrl,
                            width: 80.0,
                            height: 80.0,
                            border: Border.all(color: Colors.red, width: 1.0),
                            shape: BoxShape.circle,
                            loadStateChanged: loadStateChanged)),
                  ),
                ]),
                overflow: TextOverflow.ellipsis,
                //style: TextStyle(background: Paint()..color = Colors.red),
                maxLines: 15,
                selectionEnabled: true,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ///clear memory
          clearMemoryImageCache();

          ///clear local cahced
          clearDiskCachedImages().then((bool done) {
//            showToast(done ? "clear succeed" : "clear failed",
//                position: ToastPosition(align: Alignment.center));
            print(done);
          });
        },
        child: Text(
          "clear cache",
          textAlign: TextAlign.center,
          style: TextStyle(
            inherit: false,
          ),
        ),
      ),
    );
  }

  Widget loadStateChanged(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        return Container(
          color: Colors.grey,
        );
      case LoadState.completed:
        return null;
      case LoadState.failed:
        state.imageProvider.evict();
        return GestureDetector(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                "assets/failed.jpg",
                fit: BoxFit.fill,
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Text(
                  "load image failed, click to reload",
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          onTap: () {
            state.reLoadImage();
          },
        );
    }
    return Container();
  }

  void onTap(BuildContext context, int index) {
    Navigator.pushNamed(context, "fluttercandies://picswiper", arguments: {
      "index": index,
      "pics": listSourceRepository
          .map<PicSwiperItem>((f) => PicSwiperItem(f.imageUrl, des: f.title))
          .toList(),
    });
//    var page = PicSwiper(
//      index,
//      listSourceRepository
//          .map<PicSwiperItem>((f) => PicSwiperItem(f.imageUrl))
//          .toList(),
//    );
//    Navigator.push(
//        context,
//        Platform.isAndroid
//            ? TransparentMaterialPageRoute(builder: (_) {
//                return page;
//              })
//            : TransparentCupertinoPageRoute(builder: (_) {
//                return page;
//              }));
  }
}
