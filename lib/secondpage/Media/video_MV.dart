import 'dart:async';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoPlay extends StatefulWidget {
  const VideoPlay({super.key});

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  final _pageController = PageController(viewportFraction: 0.8);
  Timer? _timer;
  int _currentPage = 0;
  bool _autoScroll = false;

  final List<String> _videoList = [
    'https://videos.pexels.com/video-files/854183/854183-hd_1920_1080_25fps.mp4',
    '',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
  ];

  void _toggleAutoScroll() {
    setState(() {
      _autoScroll = !_autoScroll;

      if (_autoScroll) {
        _timer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (_currentPage < _videoList.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }

          _pageController.animateToPage(_currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _toggleAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      height: 250.h,
      color: Colors.grey[400],
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        itemCount: _videoList.length,
        itemBuilder: (context, index) {
          double opacity =
              (index == _currentPage - 1 || index == _currentPage + 1)
                  ? 0.3
                  : 1;

          return Opacity(
            opacity: opacity,
            child: Container(
              height: 100.r,
              width: 100.r,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.black, width: 2),
              ),
              margin: const EdgeInsets.all(20),
              child: VideoContainer(
                videoUrl: _videoList[index],
                toggleAutoScroll: _toggleAutoScroll,
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoContainer extends StatefulWidget {
  const VideoContainer({
    super.key,
    required this.videoUrl,
    required this.toggleAutoScroll,
  });

  final String videoUrl;
  final VoidCallback toggleAutoScroll;

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  CustomVideoPlayerController? _customVideoController;
  CachedVideoPlayerController? _videoController;
  String _videoDuration = "00:00";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = CachedVideoPlayerController.network(widget.videoUrl);
    try {
      await _videoController?.initialize();
      if (mounted) {
        setState(() {
          _videoDuration = _formatDuration(_videoController!.value.duration);
          _customVideoController = CustomVideoPlayerController(
            context: context,
            videoPlayerController: _videoController!,
          );
        });
      }
    } catch (e) {
      print("VIDEO INIT ERROR: $e");
      setState(() {
        _hasError = true;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text(
          'ERROR',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (_videoController?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CachedVideoPlayer(_videoController!),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(5.r),
            child: Text(
              _videoDuration,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
///////////////////////////////////////////////////////////////////
        GestureDetector(
          onTap: () {
            widget.toggleAutoScroll();
            showDialog(
              context: context,
              builder: (context) {
                _videoController?.play();
                _videoController?.setLooping(true);

                return PopScope(
                  onPopInvoked: (didPop) async {
                    _videoController?.pause();
                    widget.toggleAutoScroll();
                  },
                  child: Dialog(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: GestureDetector(
                        onLongPressStart: (details) {
                          _videoController?.setPlaybackSpeed(2);
                        },
                        onLongPressEnd: (details) {
                          _videoController?.setPlaybackSpeed(1);
                        },
                        onDoubleTap: () {
                          if (_videoController!.value.isPlaying) {
                            _videoController?.pause();
                          } else {
                            _videoController?.play();
                          }
                        },
                        child: CustomVideoPlayer(
                          customVideoPlayerController: _customVideoController!,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
///////////////////////////////////////////////////////////////////
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
