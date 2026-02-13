import 'package:flutter/material.dart';
import 'package:musicplayer/data/repositories.dart';
import 'package:musicplayer/api/bloc.dart';
import 'package:musicplayer/api/library.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "music app ",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: RepositoryProvider(
        create: (context) => MusicRepository(),
        child: BlocProvider(
          create: (context) => TrackBloc( musicRepository: context.read<MusicRepository>()),
          child: LibraryScreen(),
        )
      ),
    );
  }
}