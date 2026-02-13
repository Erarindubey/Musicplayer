import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musicplayer/data/models.dart';
import 'package:musicplayer/api/detail.dart';
import 'package:musicplayer/api/bloc.dart';



class LibraryScreen extends StatefulWidget{
  @override
  _LibraryScreenState createState() => _LibraryScreenState(); 
}

class _LibraryScreenState extends State<LibraryScreen>{
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {});
    });

    context.read<TrackBloc>().add(FetchTracks());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll(){
    if(_isBottom){
      context.read<TrackBloc>().add(FetchTracks());
    }
  }
  bool get _isBottom{
    if(!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScreenChanged(String query){
    context.read<TrackBloc>().add(SearchTracks(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Library", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        shadowColor: Colors.black,
        scrolledUnderElevation: 5,

      ),
      backgroundColor: Colors.purple[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Tracks",
                hintText: 'e.g. eminem, arijit singh, Ed Sheeran....',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onScreenChanged('');
                          }, 
                          icon: const Icon(Icons.clear)
                          )
                          : null,
                iconColor: Colors.deepPurple,
                prefixIconColor: Colors.deepPurple, 
                suffixIconColor: Colors.deepPurple,
                hoverColor: Colors.grey[70],
                filled: true,
              ),
              onChanged: _onScreenChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<TrackBloc, TrackState>(
              builder: (context, state){
                if (state.status == TrackStatus.loading){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if(state.status == TrackStatus.failure){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: Colors.red,),
                        const SizedBox(height: 16,),
                        const Text(
                                "NO INTERNET CONNECTION",
                                style: TextStyle(fontSize:16, fontWeight: FontWeight.bold )
                          ),
                        const SizedBox(height: 16,),
                        ElevatedButton(
                          onPressed: () {
                            if(state.currentQuery.isEmpty){
                              context.read<TrackBloc>().add(FetchTracks());
                            }else{
                              context.read<TrackBloc>().add(SearchTracks(state.currentQuery));
                            }
                          },
                          child: Text("retry")
                          ),
                      ],
                    ),
                  );
                }
                if(state.status == TrackStatus.success){
                  if(state.tracks.isEmpty){
                    return const Center(
                      child: Text("No Tracks Found."),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.hasreachedmax
                             ? state.tracks.length
                             : state.tracks.length +1 ,
                    itemBuilder: (BuildContext context, int index){
                      if (index >= state.tracks.length){
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                          
                          );
                      }
                      final track = state.tracks[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(track.artworkUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) => const Icon(Icons.music_note)
                            ),
                          ),
                        ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text(
                          "${track.artistName} - ${track.albumTitle}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTrack(track: track)
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              return const Center(child: Text("Search and see results!"));
              },
            )
          )
        ],
      )
    );
  }
} 