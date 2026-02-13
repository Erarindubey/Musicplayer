class Track {
  final int id;
  final String title;
  final String artistName;
  final String artworkUrl;
  final String albumTitle;
  final String? previewUrl; 

  Track({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.artworkUrl,
    this.previewUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json){
    return Track(
      id: json['trackId'],
      title: json['trackName'] ?? 'Unknown Track',
      artistName: json['artistName'] ?? 'Unknown Artist',
      artworkUrl: (json['artworkUrl100']as String?)?.replaceAll('100x100', '600x600') ?? '',
      albumTitle: json['collectionName'] ?? 'Unknown Album',
      previewUrl: json['previewUrl'],
    );
  }
}

class Lyrics {
  final String? text;
  Lyrics(this.text);
}