import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musicplayer/data/models.dart';

class MusicRepository{
  Future<List<Track>> fetchTracks({required String query, required int offset}) async {
    String searchTerm;
    final List<String> _randomKeywords = [
    // A
    'abba', 'adele', 'aerosmith', 'alan walker', 'ariana grande', 'avicii',
    // B
    'backstreet boys', 'bad bunny', 'beatles', 'beyonce', 'billie eilish', 'blackpink', 'bob marley', 'bon jovi', 'bts',
    // C
    'calvin harris', 'camila cabello', 'cardi b', 'chainsmokers', 'charlie puth', 'coldplay',
    // D
    'daft punk', 'david bowie', 'david guetta', 'demi lovato', 'doja cat', 'drake', 'dua lipa',
    // E
    'eagles', 'ed sheeran', 'elton john', 'elvis presley', 'eminem', 'enrique iglesias',
    // F
    'fall out boy', 'fifth harmony', 'flo rida', 'frank sinatra',
    // G
    'galantis', 'george michael', 'green day', 'guns n roses',
    // H
    'halsey', 'harry styles', 'hozier',
    // I
    'imagine dragons', 'iron maiden',
    // J
    'j balvin', 'jack johnson', 'jason derulo', 'jay-z', 'jennifer lopez', 'john legend', 'jonas brothers', 'justin bieber', 'justin timberlake',
    // K
    'kanye west', 'katy perry', 'khalid', 'killers', 'kygo',
    // L
    'lady gaga', 'lana del rey', 'led zeppelin', 'linkin park', 'lorde', 'luke bryan',
    // M
    'madonna', 'maroon 5', 'marshmello', 'martin garrix', 'metallica', 'michael jackson', 'miley cyrus',
    // N
    'nicki minaj', 'nirvana',
    // O
    'oasis', 'one direction', 'onerepublic',
    // P
    'panic at the disco', 'pearl jam', 'pink', 'pink floyd', 'pitbull', 'post malone',
    // Q
    'queen',
    // R
    'radiohead', 'red hot chili peppers', 'rihanna', 'rolling stones',
    // S
    'sam smith', 'selena gomez', 'shakira', 'shawn mendes', 'sia', 'snoop dogg',
    // T
    'taylor swift', 'the weeknd', 'twenty one pilots', 'travis scott',
    // U
    'u2', 'usher',
    // V
    'van halen',
    // W
    'whitney houston', 'wiz khalifa',
    // Z
    'zayn', 'zedd'
  ];

    if (query.isEmpty){
      int index = (offset / 50 ).round();
      searchTerm = _randomKeywords[index % _randomKeywords.length];
    } else {
      searchTerm = query;
    }
    final url = Uri.parse('https://itunes.apple.com/search?term=$searchTerm&limit=50&offset=$offset&media=music');
    try{
      final response = await http.get(url); 
      if (response.statusCode == 200){
        final data = json.decode(response.body);
        return data['results'].map((t)=> Track.fromJson(t)).toList().cast<Track>();
      }
      throw Exception("api error");
    }
    catch (e) {
      print(e); 
      throw Exception("NO INTERNET CONNECTION");
    }
  }

  Future<String> fetchLyrics(String artist, String title) async {
    // API-C: LRCLIB (Still works perfectly with iTunes data)
    try {
      final url = Uri.parse('https://lrclib.net/api/get?track_name=$title&artist_name=$artist');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['plainLyrics'] ?? "Lyrics not available.";
      }
      return "Lyrics not found.";
    } catch (_) {
      return "Could not fetch lyrics (No Internet).";
    }
  }

}