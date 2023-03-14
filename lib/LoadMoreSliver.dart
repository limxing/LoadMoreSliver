import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

enum LoadMoreSliverType { NONE, LOADING, NORMAL, ERROR }

///上拉加载更多，用于CustomScrollView
///author：李利锋 Date: 2023年03月14日
class LoadMoreSliver extends StatefulWidget {
  const LoadMoreSliver(
      {Key? key, required this.onLoad, this.normalBuilder, this.loadingBuilder, this.noneBuilder, this.errorBuilder})
      : super(key: key);
  final AsyncValueGetter<LoadMoreSliverType> onLoad;
  final WidgetBuilder? normalBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noneBuilder;
  final WidgetBuilder? errorBuilder;

  @override
  State<LoadMoreSliver> createState() => _LoadMoreSliverState();
}

class _LoadMoreSliverState extends State<LoadMoreSliver> {
  LoadMoreSliverType type = LoadMoreSliverType.NORMAL;

  @override
  Widget build(BuildContext context) {
    return _LoadMoreSliver(
      child: type == LoadMoreSliverType.NORMAL
          ? widget.normalBuilder != null
              ? widget.normalBuilder!.call(context)
              : const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      '上拉加载更多',
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ),
                )
          : type == LoadMoreSliverType.LOADING
              ? widget.loadingBuilder != null
                  ? widget.loadingBuilder!.call(context)
                  : UnconstrainedBox(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CupertinoActivityIndicator(),
                            SizedBox(
                              width: 10,
                            ),
                            Text('加载中...', style: TextStyle(fontSize: 13, color: Colors.black45))
                          ],
                        ),
                      ),
                    )
              : type == LoadMoreSliverType.NONE
                  ? widget.noneBuilder != null
                      ? widget.noneBuilder!.call(context)
                      : const SizedBox(
                          height: 50,
                          child: Center(child: Text('没有更多了', style: TextStyle(fontSize: 13, color: Colors.black45))),
                        )
                  : widget.errorBuilder != null
                      ? widget.errorBuilder!.call(context)
                      : CupertinoButton(
                          minSize: 50,
                          child: const Center(
                              child: Text('加载失败 点击重试', style: TextStyle(fontSize: 13, color: Colors.black45))),
                          onPressed: () {
                            type = LoadMoreSliverType.LOADING;
                            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                              setState(() {});
                              widget.onLoad.call().then((value) {
                                setState(() {
                                  type = value;
                                });
                              });
                            });
                          }),
      callback: () {
        if (type == LoadMoreSliverType.NORMAL) {
          type = LoadMoreSliverType.LOADING;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {});
            widget.onLoad.call().then((value) {
              setState(() {
                type = value;
              });
            });
          });
        }
      },
    );
  }
}

class _LoadMoreSliver extends SingleChildRenderObjectWidget {
  const _LoadMoreSliver({super.child, required this.callback});

  final VoidCallback callback;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _LoadMoreRenderObject(callback);
  }
}

class _LoadMoreRenderObject extends RenderSliverSingleBoxAdapter {
  final VoidCallback callback;

  _LoadMoreRenderObject(this.callback);

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    geometry = SliverGeometry(
      scrollExtent: cacheExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
    if (paintedChildSize == childExtent) {
      callback();
    }
  }
}
