import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/post.dart';

class InfiniteScrollView extends ConsumerStatefulWidget {
  const InfiniteScrollView({super.key});

  static const String name = 'infinite-scroll';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends ConsumerState<InfiniteScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final notifier = ref.read(postProvider.notifier);
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 &&
          !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(postProvider)
        .when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (posts) => ListView.builder(
            controller: _controller,
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index < posts.length) {
                final post = posts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(post.id.toString())),
                    title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(post.body),
                  ),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        );
  }
}
