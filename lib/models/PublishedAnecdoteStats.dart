class PublishedAnecdoteStats {
  const PublishedAnecdoteStats({
    required this.total,
    required this.editionCount,
    required this.latestEditionCount,
    this.latestEditionNumber,
  });

  final int total;
  final int editionCount;
  final int latestEditionCount;
  final int? latestEditionNumber;
}
