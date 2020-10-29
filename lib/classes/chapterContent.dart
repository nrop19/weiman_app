class ChapterContent {
  final List<String> images;
  final bool hasNextPage;

  ChapterContent(this.images, this.hasNextPage);

  @override
  String toString() {
    return 'ChapterContent images:${images.length} nexPage:$hasNextPage';
  }
}
