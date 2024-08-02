import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keren_app/secondpage/Media/photo_MV.dart';
import 'package:keren_app/secondpage/Media/video_MV.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const VideoPlay(),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const AudioRecord();
                  },
                );
              },
              child: const Text('Voice Recorder'),
            ),
            const PhotoGrid(),
          ]
        ),
      ),
    );
  }
}

class AudioRecord extends StatefulWidget {
  const AudioRecord({super.key});

  @override
  _AudioRecordState createState() => _AudioRecordState();
}

class _AudioRecordState extends State<AudioRecord> {
  final _recorder = FlutterSoundRecorder();
  final _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPaused = false;
  String _recordPath = '';
  Duration _recordedDuration = Duration.zero;
  Timer? _timer;

  var _audioFilesFuture = FirebaseFirestore.instance.collection('Audios').get();

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      final Directory tempDir = Directory.systemTemp;
      final String path = '${tempDir.path}/temp.wav';
      await _recorder.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
        _recordPath = path;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordedDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resumeRecorder();
      _startRecording();
    } else {
      await _recorder.pauseRecorder();
      _timer?.cancel();
    }
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _timer?.cancel();

    final UploadTask uploadTask = FirebaseStorage.instance
        .ref('audio/${DateTime.now().microsecondsSinceEpoch}.wav')
        .putFile(File(_recordPath));

    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('Audios').add({
      'url': downloadUrl,
      'duration':
          '${_recordedDuration.inMinutes}:${_recordedDuration.inSeconds.toString().padLeft(2, '0')}',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordedDuration = Duration.zero;
      _audioFilesFuture = FirebaseFirestore.instance.collection('Audios').get();
    });
  }

  Future<void> _playAudio(String url) async {
    await _player.setUrl(url);
    _player.play();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600.h,
      width: 600.w,
      child: Column(children: [
        StreamBuilder<bool>(
          stream: _player.playingStream,
          builder: (context, snapshot) {
            final bool isPlaying = snapshot.data ?? false;
            return IconButton(
              onPressed: () async {
                if (isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
              ),
            );
          },
        ),
///////////////////////////////////////////////////////////////////
        StreamBuilder(
          stream: _player.positionStream,
          builder: (context, snapshot) {
            final Duration position = snapshot.data ?? Duration.zero;
            return StreamBuilder(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final Duration duration = snapshot.data ?? Duration.zero;
                return Slider(
                  inactiveColor: Colors.grey,
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _player.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            );
          },
        ),
///////////////////////////////////////////////////////////////////
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () async {
              _isRecording ? await _togglePause() : await _startRecording();
            },
            child: Text(
                _isRecording ? (_isPaused ? 'Resume' : 'Pause') : 'Record'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.record_voice_over,
              color:
                  _isRecording ? (_isPaused ? Colors.amber : Colors.red) : null,
            ),
          ),
          Text(
              '${_recordedDuration.inMinutes.toString().padLeft(2)}:${_recordedDuration.inSeconds.toString().padLeft(2, '0')}'),
        ]),
        ElevatedButton(
          onPressed: _isRecording ? _stopRecording : null,
          child: const Text('Publish')
        ),
///////////////////////////////////////////////////////////////////
        Container(
          height: 300.h,
          width: 500.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: FutureBuilder(
            future: _audioFilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final documents = snapshot.data?.docs ?? [];
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot doc = documents[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.amber, width: 2),
                    ),
                    onTap: () async {
                      await _playAudio(data['url']);
                    },
                    leading: Text(data['duration'].toString()),
                    title: Text((data['createdAt']).toString()),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await FirebaseStorage.instance
                              .refFromURL(data['url'])
                              .delete();
                          await FirebaseFirestore.instance
                              .collection('Audios')
                              .doc(doc.id)
                              .delete();
                          setState(() {
                            _audioFilesFuture = FirebaseFirestore.instance
                                .collection('Audios')
                                .get();
                          });
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
