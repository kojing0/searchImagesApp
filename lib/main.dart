import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List<PixabayImage> pixabayImages = [];

  Future<void> fetchImages(String text) async {
    final Response response = await Dio().get(
      'https://pixabay.com/api',
      queryParameters: {
        'key': '42379779-257466f3af0c1b321a06e35f9',
        'q': text,
        'image_type': 'photo',
        'per_page': 100,
      },
    );
    final List hits = response.data['hits'];
    pixabayImages = hits.map((e) => PixabayImage.fromMap(e)).toList();

    setState(() {});
  }

  Future<void> shareImage(String url) async {
    final Directory dir = await getTemporaryDirectory();
    final Response response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final File imageFile =
        await File('${dir.path}/image.png').writeAsBytes(response.data);
    await Share.shareFiles([imageFile.path]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('book');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            onFieldSubmitted: (text) {
              fetchImages(text);
            },
            decoration:
                const InputDecoration(fillColor: Colors.white, filled: true),
          ),
        ),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: pixabayImages.length,
            itemBuilder: (context, index) {
              final pixabayImage = pixabayImages[index];
              return InkWell(
                onTap: () async {
                  shareImage(pixabayImage.webformatURL);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      pixabayImage.previewURL,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 14,
                              ),
                              Text('${pixabayImage.likes}'),
                            ],
                          )),
                    )
                  ],
                ),
              );
            }));
  }
}

class PixabayImage {
  final String previewURL;
  final int likes;
  final String webformatURL;

  PixabayImage({
    required this.previewURL,
    required this.likes,
    required this.webformatURL,
  });

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      previewURL: map['previewURL'],
      likes: map['likes'],
      webformatURL: map['webformatURL'],
    );
  }
}
