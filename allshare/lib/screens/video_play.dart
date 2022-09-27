import 'dart:io';
import 'dart:typed_data';
import 'package:allshare/controller/converter.dart';
import 'package:allshare/controller/dart.dart'
    if (dart.library.html) 'dart:html';
import 'package:allshare/data/app_states.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlay extends StatefulWidget {
  final int index;
  final AppStates appStates;

  const VideoPlay({Key? key, required this.appStates, required this.index})
      : super(key: key);

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  Uint8List? imageBinay;
  final Converter converter = Converter();

  //Set InitState
  @override
  void initState() {
    super.initState();

    // convert Uint8List to Blob ,
    // https://stackoverflow.com/questions/65821003/flutter-web-playing-uint8list-n-videoplayer/65834130
    //Play Video in Web using Uint8List bytes
    Uint8List bytes = converter.getUint8List(
        widget.appStates.receivedItems.value[widget.index].binary);
    final blob = Blob([bytes]); //Blob will carry array of bytes
    final url = Url.createObjectUrlFromBlob(blob);
    _controller = VideoPlayerController.network(url);
    print(blob);
    print(url);
    print(_controller);

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allshare Video Demo'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            // return AspectRatio(
            //   aspectRatio: _controller.value.aspectRatio,
            //   // Use the VideoPlayer widget to display the video.
            //   child: VideoPlayer(_controller),
            // );
            return Stack(
              children: <Widget>[
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                //FURTHER IMPLEMENTATION
              ],
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
