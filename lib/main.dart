import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 배운점
// GridView.count()를 통해 그리드 형식으로 요소 배치
// notifyListeners로 Consumer 이하를 새로 호출 (새로고침 기능)

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CatService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// 고양이 서비스
class CatService extends ChangeNotifier {
  // 고양이 사진 담을 변수
  List<String> catImages = [];

  // 종아요 사진 담을 변수
  List<String> heartImages = [];

  CatService() {
    getRandomCatImages();
  }

  // 랜덤 고양이 사진 API 호출
  void getRandomCatImages() async {
    Response result = await Dio().get(
        "https://api.thecatapi.com/v1/images/search?limit=10&mime_types=jpg");
    for (var i = 0; i < result.data.length; i++) {
      var image = result.data[i]["url"];
      catImages.add(image);
    }
    notifyListeners();
  }

  void toggleHeartImage(String catImage) {
    if (heartImages.contains(catImage)) {
      heartImages.remove(catImage); // 이미 좋아요 한 경우
    } else {
      heartImages.add(catImage); // 종아요를 안 한 경우
    }
    notifyListeners();
  }
}

/// 홈 페이지
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(
      builder: (context, catService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Random Cats",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: [
              // 좋아요 페이지로 이동
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                },
              )
            ],
          ),
          // 고양이 사진 목록
          body: GridView.count(
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.all(8),
            crossAxisCount: 2,
            children: List.generate(
              catService.catImages.length,
              (index) {
                String catImage = catService.catImages[index];
                return GestureDetector(
                  onTap: () {
                    catService.toggleHeartImage(catImage);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          catImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Icon(
                          Icons.favorite,
                          color: catService.heartImages.contains(catImage)
                              ? Colors.pink
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// 좋아요 페이지
class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(
      builder: (context, catService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("좋아요"),
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
