# load_more_sliver

Flutter widget for CustomScrollView. LoadMore data from net ,just like CupertinoSliverRefreshControl.  
用于 CustomScrollView 的上拉加载更多的sliver组件  
<img src="demo_show.gif" height="640" width="295"/>
## Getting Started

### Copy File
Copy lib/LoadMoreSliver.dart to your project.
### Set
```dart
  CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
     ...
      LoadMoreSliver(
        onLoad: () {
         
        },
      )
    ],
  )
```
可选参数
```dart
final WidgetBuilder? normalBuilder;
final WidgetBuilder? loadingBuilder;
final WidgetBuilder? noneBuilder;
final WidgetBuilder? errorBuilder;
```


## License
LoadMoreSliver is available under the MIT license.