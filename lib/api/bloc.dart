import 'dart:math';
import 'package:musicplayer/data/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musicplayer/data/repositories.dart';
import 'package:rxdart/rxdart.dart';



// Events
abstract class TrackEvent{}

class FetchTracks extends TrackEvent{}

class SearchTracks extends TrackEvent{
  final String query;
  SearchTracks(this.query);
} // events


// States
enum TrackStatus { initial, success, failure, loading}

class TrackState {
  final TrackStatus status;
  final List<Track> tracks;
  final bool hasreachedmax;
  final String currentQuery;
  final int pageIndex;
  final String errorMessage;

  TrackState({
    this.status = TrackStatus.initial,
    this.tracks = const [],
    this.hasreachedmax = false,
    this.currentQuery = '',
    this.pageIndex = 0,
    this.errorMessage = '', 
  });

  TrackState copyWith({
    TrackStatus? status, 
    List<Track>? tracks, 
    bool? hasreachedmax,
    String? currentQuery,
    int? pageIndex,
    String? errorMessage,
  }) {
    return TrackState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      hasreachedmax: hasreachedmax ?? this.hasreachedmax,
      currentQuery: currentQuery ?? this.currentQuery,
      pageIndex: pageIndex ?? this.pageIndex,
      errorMessage: errorMessage ?? this.currentQuery
    );
  }
}//states

//bloc
class TrackBloc extends Bloc<TrackEvent, TrackState>{
  final MusicRepository musicRepository;
  TrackBloc({required this.musicRepository}) : super(TrackState()){
    on<SearchTracks>((event, emit) async {
      emit(state.copyWith(
        status: TrackStatus.loading,
        tracks: [],
        pageIndex: 0,
        hasreachedmax: false,
        errorMessage: ''
        ));
        try{
          final tracks = await musicRepository.fetchTracks(
            query: event.query,
            offset: 0
          );
          emit(state.copyWith(
            status: TrackStatus.success,
            tracks: tracks,
            pageIndex: 1,
            hasreachedmax: false,
          ));
        }catch(e) {
          emit(state.copyWith(
            status: TrackStatus.failure,
            errorMessage: e.toString()
          ));
        }
    }, transformer: (events, mapper) => events.debounceTime(Duration(milliseconds: 500)).asyncExpand(mapper)
    );
    on<FetchTracks>((event, emit) async {
      if (state.hasreachedmax){
        return;
      }
      try{
        if(state.status == TrackStatus.initial){
          emit(state.copyWith(
            status: TrackStatus.loading
          ));
          }
        final newTracks = await musicRepository.fetchTracks(
          query: state.currentQuery,
          offset: state.pageIndex * 50
          );  
        
        emit(newTracks.isEmpty
          ? state.copyWith(hasreachedmax: true)
          : state.copyWith(
            status: TrackStatus.success,
            tracks: List.of(state.tracks)..addAll(newTracks),
            pageIndex: state.pageIndex + 1,
            hasreachedmax: false,
            ));
        }catch(e){
          emit(state.copyWith(status: TrackStatus.failure, errorMessage: e.toString()));
        }
    });
  }
}//bloc