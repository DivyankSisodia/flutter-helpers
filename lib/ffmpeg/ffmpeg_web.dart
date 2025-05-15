// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FFmpeg ffmpeg;
  bool isLoaded = false;
  String? selectedFile;
  String? conversionStatus;

  FilePickerResult? filePickerResult;

  final progress = ValueNotifier<double?>(null);
  final statistics = ValueNotifier<String?>(null);

  late Future<List<Uint8List>> dashFramesFuture;

  @override
  void initState() {
    dashFramesFuture = _genDashFrames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Is FFmpeg loaded $isLoaded and selected $selectedFile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              OutlinedButton(
                onPressed: loadFFmpeg,
                child: const Text('Load FFmpeg'),
              ),
              OutlinedButton(
                onPressed: isLoaded ? pickFile : null,
                child: const Text('Pick File'),
              ),
              OutlinedButton(
                onPressed: selectedFile == null ? null : extractFirstFrame,
                child: const Text('Extract First Frame'),
              ),
              OutlinedButton(
                onPressed: selectedFile == null ? null : createPreviewVideo,
                child: const Text('Create Preview Image'),
              ),
              Text('Conversion Status : $conversionStatus'),
              OutlinedButton(
                onPressed: selectedFile == null ? null : create720PQualityVideo,
                child: const Text('Create 720P Quality Videos'),
              ),
              OutlinedButton(
                onPressed: selectedFile == null ? null : create480PQualityVideo,
                child: const Text('Create 480P Quality Videos'),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: progress,
                builder: (context, value, child) {
                  return value == null
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Exporting ${(value * 100).ceil()}%'),
                            const SizedBox(width: 6),
                            const CircularProgressIndicator(),
                          ],
                        );
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: statistics,
                builder: (context, value, child) {
                  return value == null
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(value),
                            const SizedBox(width: 6),
                            const CircularProgressIndicator(),
                          ],
                        );
                },
              ),
              Image.network(
                "https://images.pexels.com/photos/276267/pexels-photo-276267.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                height: 96,
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: 500,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: FutureBuilder<List<Uint8List>>(
                  future: dashFramesFuture,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, index) {
                            return Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Image.memory(snapshot.data![index]),
                            );
                          },
                          separatorBuilder: (ctx, index) {
                            return const SizedBox(width: 8);
                          },
                        );
                      } else {
                        return const Center(child: Text('No frames available'));
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: isLoaded ? () => createGif() : null, child: const Text('Create Gif from frames'))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: checkLoaded,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    progress.dispose();
    statistics.dispose();
    super.dispose();
  }

  Future<void> loadFFmpeg() async {
    ffmpeg = createFFmpeg(
      CreateFFmpegParam(
        log: true,
        corePath: "https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js",
      ),
    );

    ffmpeg.setProgress(_onProgressHandler);
    ffmpeg.setLogger(_onLogHandler);

    await ffmpeg.load();

    checkLoaded();
  }

  void checkLoaded() {
    setState(() {
      isLoaded = ffmpeg.isLoaded();
    });
  }

  Future<void> pickFile() async {
    filePickerResult = await FilePicker.platform.pickFiles(type: FileType.video);

    if (filePickerResult != null && filePickerResult!.files.single.bytes != null) {
      /// Writes File to memory
      ffmpeg.writeFile('input.mp4', filePickerResult!.files.single.bytes!);

      setState(() {
        selectedFile = filePickerResult!.files.single.name;
      });
    }
  }

  /// Extracts First Frame from video
  Future<void> extractFirstFrame() async {
    setState(() {
      conversionStatus = 'Started';
    });
    await ffmpeg.run(['-i', 'input.mp4', '-vf', "select='eq(n,0)'", '-vsync', '0', 'frame1.webp']);
    setState(() {
      conversionStatus = 'Saving';
    });
    final data = ffmpeg.readFile('frame1.webp');
    setState(() {
      conversionStatus = 'Downloading';
    });

    try {
      final blob = html.Blob([data]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'frame1.webp')
        ..click();
      html.Url.revokeObjectUrl(url);
      setState(() {
        conversionStatus = 'Completed';
      });
    } catch (e) {
      print('Error triggering file download: $e');
      setState(() {
        conversionStatus = 'Error during download';
      });
    }
  }

  /// Creates Preview Image of Video
  Future<void> createPreviewVideo() async {
    setState(() {
      conversionStatus = 'Started';
    });
    await ffmpeg.run(['-i', 'input.mp4', '-t', '5.0', '-ss', '2.0', '-s', '480x720', '-f', 'webp', '-r', '5', 'previewWebp.webp']);
    setState(() {
      conversionStatus = 'Saving';
    });
    final previewWebpData = ffmpeg.readFile('previewWebp.webp');
    setState(() {
      conversionStatus = 'Downloading';
    });

    try {
      final blob = html.Blob([previewWebpData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'previewWebp.webp')
        ..click();
      html.Url.revokeObjectUrl(url);
      setState(() {
        conversionStatus = 'Completed';
      });
    } catch (e) {
      print('Error triggering file download: $e');
      setState(() {
        conversionStatus = 'Error during download';
      });
    }
  }

  Future<void> create720PQualityVideo() async {
    setState(() {
      conversionStatus = 'Started';
    });
    await ffmpeg.run(['-i', 'input.mp4', '-s', '720x1280', '-c:a', 'copy', '720P_output.mp4']);
    setState(() {
      conversionStatus = 'Saving';
    });
    final hqVideo = ffmpeg.readFile('720P_output.mp4');
    setState(() {
      conversionStatus = 'Downloading';
    });

    try {
      final blob = html.Blob([hqVideo]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '720P_output.mp4')
        ..click();
      html.Url.revokeObjectUrl(url);
      setState(() {
        conversionStatus = 'Completed';
      });
    } catch (e) {
      print('Error triggering file download: $e');
      setState(() {
        conversionStatus = 'Error during download';
      });
    }
  }

  Future<void> create480PQualityVideo() async {
    setState(() {
      conversionStatus = 'Started';
    });
    await ffmpeg.run(['-i', 'input.mp4', '-s', '480x720', '-c:a', 'copy', '480P_output.mp4']);
    setState(() {
      conversionStatus = 'Saving';
    });
    final hqVideo = ffmpeg.readFile('480P_output.mp4');
    setState(() {
      conversionStatus = 'Downloading';
    });

    try {
      final blob = html.Blob([hqVideo]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '480P_output.mp4')
        ..click();
      html.Url.revokeObjectUrl(url);
      setState(() {
        conversionStatus = 'Completed';
      });
    } catch (e) {
      print('Error triggering file download: $e');
      setState(() {
        conversionStatus = 'Error during download';
      });
    }
  }

  /// Creates GIF from PNG frames
  Future<void> createGif() async {
    setState(() {
      conversionStatus = 'Started';
    });

    // Write PNG frames to FFmpeg memory
    for (int i = 0; i <= 10; i++) {
      final ByteData data = await rootBundle.load(i < 10 ? 'flutter_dash_frames/flutter_dash_00$i.png' : 'flutter_dash_frames/flutter_dash_0$i.png');
      final file = data.buffer.asUint8List();
      ffmpeg.writeFile(i < 10 ? 'flutter_dash_00$i.png' : 'flutter_dash_0$i.png', file);
    }

    // Generate palette
    await ffmpeg.run([
      '-framerate',
      '30',
      '-i',
      'flutter_dash_%03d.png',
      '-vf',
      'palettegen',
      'palette.png',
    ]);

    // Create GIF using palette
    await ffmpeg.run([
      '-framerate',
      '30',
      '-i',
      'flutter_dash_%03d.png',
      '-i',
      'palette.png',
      '-filter_complex',
      '[0:v][1:v]paletteuse',
      'flutter_dash.gif',
    ]);

    setState(() {
      conversionStatus = 'Saving';
    });
    final gifData = ffmpeg.readFile('flutter_dash.gif');
    setState(() {
      conversionStatus = 'Downloading';
    });

    try {
      final blob = html.Blob([gifData]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'flutter_dash.gif')
        ..click();
      html.Url.revokeObjectUrl(url);
      setState(() {
        conversionStatus = 'Completed';
      });
    } catch (e) {
      print('Error triggering file download: $e');
      setState(() {
        conversionStatus = 'Error during download';
      });
    }
  }

  /// Generates List of frames to show in UI
  Future<List<Uint8List>> _genDashFrames() async {
    List<Uint8List> frames = [];
    for (int i = 0; i <= 43; i++) {
      final ByteData data = await rootBundle.load(i < 10 ? 'flutter_dash_frames/flutter_dash_00$i.png' : 'flutter_dash_frames/flutter_dash_0$i.png');
      final image = data.buffer.asUint8List();
      frames.add(image);
    }
    return frames;
  }

  void _onProgressHandler(ProgressParam progress) {
    final isDone = progress.ratio >= 1;

    this.progress.value = isDone ? null : progress.ratio;
    if (isDone) {
      statistics.value = null;
    }
  }

  static final regex = RegExp(
    r'frame\s*=\s*(\d+)\s+fps\s*=\s*(\d+(?:\.\d+)?)\s+q\s*=\s*([\d.-]+)\s+L?size\s*=\s*(\d+)\w*\s+time\s*=\s*([\d:\.]+)\s+bitrate\s*=\s*([\d.]+)\s*(\w+)/s\s+speed\s*=\s*([\d.]+)x',
  );

  void _onLogHandler(LoggerParam logger) {
    if (logger.type == 'fferr') {
      final match = regex.firstMatch(logger.message);

      if (match != null) {
        // Indicates the number of frames that have been processed so far
        final frame = match.group(1);
        // Current frame rate
        final fps = match.group(2);
        // Quality: 0.0 indicates lossless compression; other values indicate lossy compression
        final q = match.group(3);
        // Size of the output file so far
        final size = match.group(4);
        // Time elapsed since the beginning of the conversion
        final time = match.group(5);
        // Current output bitrate
        final bitrate = match.group(6);
        // Bitrate unit (e.g., 'kbits/s')
        final bitrateUnit = match.group(7);
        // Speed of conversion relative to real-time
        final speed = match.group(8);

        statistics.value = 'frame: $frame, fps: $fps, q: $q, size: $size, time: $time, bitrate: $bitrate$bitrateUnit, speed: $speed';
      }
    }
  }
}