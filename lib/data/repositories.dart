import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musicplayer/data/models.dart';

class MusicRepository{
  Future<List<Track>> fetchTracks({required String query, required int offset}) async {
    String searchTerm;
    final List<String> _randomKeywords = ['love', 'blue', 'sky', 'heart', 'star', 'night', 'rain'];


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