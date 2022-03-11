import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        accentColor: Color.fromARGB(255, 230, 0, 18),
        disabledColor: Color.fromARGB(255, 200, 200, 200),
        primaryColorLight: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.yuseiMagicTextTheme(Theme.of(context).textTheme),
      ),
      home: const MyHomePage(title: 'YOSHIKEI APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _value = 0.0;
  Map<String, dynamic> menu_list = {};
  List<int> activeIndex = [];
  bool loading = true;
  void getMenu() async{
    var uri = Uri.parse('http://52.23.160.26:5000/getMenuForApp');
    http.Response res = await http.get(uri);
    if (res.statusCode == 200) {
      setState(() {
        menu_list = jsonDecode(res.body);
        activeIndex = List.generate(menu_list["body"].length, (i)=>0);
        loading = false;
      });
    } else {
        throw Exception('Failed to load post');
    }
  }

  @override
  void initState(){
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network("https://www.you-shoku.net/img/base/yoshikeilogo.png", height: 40, width: double.infinity,),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: loading ? Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 230, 0, 18)))
            )
          ) : Column(
            children: <Widget>[
              for(var i=0; i<menu_list["body"].length; i++)...{
                Container(
                  height: 40,
                  color: Theme.of(context).accentColor,
                  alignment: Alignment.center,
                  child: Text(
                    menu_list["body"][i]["date"], 
                    style: GoogleFonts.hachiMaruPop(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 18,
                    ),
                  ),
                ),
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 400,
                    initialPage: 0,
                    viewportFraction: 1,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) => setState(() {
                      activeIndex[i] = index;
                    }),
                  ),
                  itemCount: 3,
                  itemBuilder: (context, index, realIndex) {
                    return buildImage(menu_list["body"][i]["menu" + (index+1).toString() + "_img"], index, i);
                  },
                ),
                buildIndicator(activeIndex[i]),
                Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 50),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "・" + menu_list["body"][i]["menu1"], 
                        style: TextStyle(
                          fontSize: 18, 
                          color: (menu_list["body"][i]["sold"] == 1) ? Theme.of(context).disabledColor : Colors.black87
                        ),
                      ),
                      Text(
                        "・" + menu_list["body"][i]["menu2"],
                        style: TextStyle(
                          fontSize: 18, 
                          color: (menu_list["body"][i]["sold"] == 1) ? Theme.of(context).disabledColor : Colors.black87
                        ),
                      ),
                      Text(
                        "・" + menu_list["body"][i]["menu3"],
                        style: TextStyle(
                          fontSize: 18, 
                          color: (menu_list["body"][i]["sold"] == 1) ? Theme.of(context).disabledColor : Colors.black87
                        ),
                      )
                    ],
                  )
                ),
              },
            ],
          ),
        )
      ),
    );
  }

  Widget buildImage(path, index, i) => Container(
    margin: EdgeInsets.all(10),
    child: Image.network(
      path, 
      fit: BoxFit.cover,
      color: Theme.of(context).primaryColorLight.withOpacity(0.5),
      colorBlendMode: (menu_list["body"][i]["sold"] == 1) ? BlendMode.modulate : BlendMode.dst
    ),
  );
  Widget buildIndicator(i) => AnimatedSmoothIndicator(
    activeIndex: i,
    count: 3,
    effect: JumpingDotEffect(
        dotHeight: 10,
        dotWidth: 10,
        activeDotColor: Theme.of(context).accentColor,
        dotColor: Theme.of(context).disabledColor),
  );
}
