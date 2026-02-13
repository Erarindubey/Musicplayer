import 'package:musicplayer/data/models.dart';
import 'package:musicplayer/data/repositories.dart';
import 'package:flutter/material.dart';

class DetailTrack extends StatefulWidget{
  final Track track;
  const DetailTrack({
    Key? key, required this.track
  }) : super(key: key);
  @override  
  _DetailTrackState createState() => _DetailTrackState();
}

class _DetailTrackState extends State<DetailTrack>{
  final MusicRepository _repository = MusicRepository();
  late Future<String> _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = _repository.fetchLyrics(
      widget.track.artistName,
      widget.track.title
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.track.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        elevation: 0,
        shadowColor: Colors.black,
        scrolledUnderElevation: 5,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'album_${widget.track.id}',
              child: Container(
                height: 300,
                width: 300, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Colors.black26, 
                    blurRadius: 15, 
                    offset: const Offset(0, 10)
                  ),
                  ], 
                  image: DecorationImage(
                    image: NetworkImage(widget.track.artworkUrl),
                    fit: BoxFit.cover, 
                    onError: (_,__) => const Icon(Icons.album, size: 100,) 
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Text(
              widget.track.title, 
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            Text(
              "${widget.track.artistName} - ${widget.track.albumTitle}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30,),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lyrics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const Divider(height: 30,), 

            FutureBuilder<String>(
              future: _lyricsFuture, 
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0), 
                      child: CircularProgressIndicator(),
                      ),
                  );
                }
                if (snapshot.hasError){
                  return const Text(
                    "NO INTERNET CONNECTION", 
                    style: TextStyle(color: Colors.red),
                  );
                }

                return Text(
                  snapshot.data ?? "No lyrics found", 
                  style: const TextStyle(
                    fontSize: 16, 
                    height: 1.6, 
                    fontStyle: FontStyle.italic,
                    ),
                );
              }
            )
          ],
        )
      )
    );
  }
}