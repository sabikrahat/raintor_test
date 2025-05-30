// providers/post_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raintor_test/features/infinite_scroll/model/post.dart';

import '../service/post.dart';

typedef PostNotifier = AsyncNotifierProvider<PostProvider, List<PostModel>>;

final postProvider = PostNotifier(PostProvider.new);

class PostProvider extends AsyncNotifier<List<PostModel>> {
  List<PostModel> _allPosts = [];
  int _currentPage = 0;
  final int _perPage = 10;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<PostModel>> build() async {
    _allPosts = await fetchPosts();
    _currentPage = 1;
    return _allPosts.take(_perPage).toList();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    await Future.delayed(Duration(seconds: 1));
    final nextPosts = _allPosts.skip(_currentPage * _perPage).take(_perPage).toList();

    if (nextPosts.isNotEmpty) {
      _currentPage++;
      state = AsyncData([...state.value!, ...nextPosts]);
    }

    _isLoadingMore = false;
  }
}
