import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //main에서 async를 사용하기 위해서 필요

  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CatService(prefs)),
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

  // 좋아요를 한 이미지
  List<String> favoriteImages = [];

  SharedPreferences prefs;

  CatService(this.prefs) {
    getRandomCatImages();

    //SharedPreferences에서 데이터 불러오기, null 일 경우 default 값인 [] 이 설정됨
    favoriteImages = prefs.getStringList("favorites") ?? [];
  }

  //램덤 고양이 사진 API 호출
  void getRandomCatImages() async {
    Response result = await Dio().get(
        "https://api.thecatapi.com/v1/images/search?limit=10&mime_types=jpg");
    print(result.data);

    for (var i = 0; i < result.data.length; i++) {
      var map = result.data[i];
      print(map);
      print(map["url"]);
      catImages.add(map["url"]);
    }
    notifyListeners();
  }

  void toggleFavoriteImage(String catImage) {
    if (favoriteImages.contains(catImage)) {
      favoriteImages.remove(catImage); //이미 존재하므로 삭제
    } else {
      favoriteImages.add(catImage); //새로 추가
    }

    prefs.setStringList("favorites", favoriteImages);

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
            title: Text("랜덤 고양이"),
            backgroundColor: Colors.amber,
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
                    //아이템을 클릭하는 경우
                    catService.toggleFavoriteImage(catImage);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        //fill: top/left/bottom/right 모두 0으로 해서 화면에 꽉 채움
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
                            color: catService.favoriteImages.contains(catImage)
                                ? Colors.amber
                                : Colors.transparent,
                          )),
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
            backgroundColor: Colors.amber,
          ),
          body: GridView.count(
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.all(8),
            crossAxisCount: 2,
            children: List.generate(
              catService.favoriteImages.length,
              (index) {
                String catImage = catService.favoriteImages[index];
                return GestureDetector(
                  onTap: () {
                    //아이템을 클릭하는 경우
                    catService.toggleFavoriteImage(catImage);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        //fill: top/left/bottom/right 모두 0으로 해서 화면에 꽉 채움
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
                            color: catService.favoriteImages.contains(catImage)
                                ? Colors.amber
                                : Colors.transparent,
                          )),
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
