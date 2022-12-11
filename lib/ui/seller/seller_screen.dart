import 'package:qatargates/custom_widgets/buttons/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qatargates/custom_widgets/ad_item/ad_item.dart';
import 'package:qatargates/custom_widgets/no_data/no_data.dart';
import 'package:qatargates/custom_widgets/safe_area/page_container.dart';
import 'package:qatargates/locale/app_localizations.dart';
import 'package:qatargates/models/ad.dart';
import 'package:qatargates/providers/auth_provider.dart';
import 'package:qatargates/providers/home_provider.dart';
import 'package:qatargates/providers/seller_ads_provider.dart';
import 'package:qatargates/ui/ad_details/ad_details_screen.dart';
import 'package:qatargates/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:qatargates/utils/error.dart';
import 'package:qatargates/networking/api_provider.dart';
import 'package:qatargates/utils/commons.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:qatargates/providers/auth_provider.dart';


class SellerScreen extends StatefulWidget {
  final String userId;

  const SellerScreen({Key key, this.userId}) : super(key: key);
  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class FruitsList {
  String name;
  int index;
  FruitsList({this.name, this.index});
}

class _SellerScreenState extends State<SellerScreen> with TickerProviderStateMixin{
double _height = 0 , _width = 0;
HomeProvider _homeProvider;
ApiProvider _apiProvider = ApiProvider();
AnimationController _animationController;
AuthProvider _authProvider ;

bool checkedValue=false;
bool checkedValue1=false;


// Default Radio Button Item
  String radioItem = 'نعم';

  // Group Value for Radio Button.
  int id = 1;

  List<FruitsList> fList = [
    FruitsList(
      index: 1,
      name: "نعم",
    ),
    FruitsList(
      index: 0,
      name: "لا",
    ),
  ];

  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


Widget _buildBodyItem(){
  return ListView(
    children: <Widget>[
         SizedBox(
            height: 80,
          ),

      Container(
        alignment: Alignment.center,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: accentColor,
              backgroundImage: NetworkImage(_homeProvider.currentSellerPhoto),
              maxRadius: 40,
            ),


          ],
        ),
      ),




          Container(
          alignment: Alignment.center,
            child: Text(" رقم العضوية :- "+ _homeProvider.currentSeller,style: TextStyle(color: Colors.black),),
          ),
Padding(padding: EdgeInsets.all(5)),
      Container(
        alignment: Alignment.center,
        child: Text(" الاسم:- "+ _homeProvider.currentSellerName,style: TextStyle(color: Colors.black),),
      ),
      Padding(padding: EdgeInsets.all(5)),
      Container(
        alignment: Alignment.center,
        child: Text(" البريد الالكتروني:- "+ _homeProvider.currentSellerEmail,style: TextStyle(color: Colors.black),),
      ),

      Padding(padding: EdgeInsets.all(5)),


      Container(
  height: 50,
  width: _width*.50,
  margin: EdgeInsets.symmetric(
  horizontal: _width * 0.20, vertical: _height * 0.01),
  decoration: BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(10.0)),
  border: Border.all(
  color: mainAppColor.withOpacity(0.9),
  ),
  ),



child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    Container(
      alignment: Alignment.center,
      child: Text(_homeProvider.currentSellerPhone,style: TextStyle(color: Colors.black),),
    ),

    GestureDetector(
      onTap: (){
        launch(
            "tel://${_homeProvider.currentSellerPhone}");
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: _width * 0.025),
          child: Image.asset('assets/images/callnow.png')),
    )
  ],
),
  ),



    Row(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[



        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(_homeProvider.currentLang=="ar"?"متابعة البائع":"Follow seller",style: TextStyle(color: mainAppColor,fontSize: 17),),
          ),
          onTap: () async{
            if(_authProvider.currentUser!=null){


              final results = await _apiProvider
                  .post("https://qatar-gates.com/api/follow2" , body: {
                "follow_user": _authProvider.currentUser.userId,
                "follow_user1": _homeProvider.currentSeller,
              });


              if (results['response'] == "1") {
                Commons.showToast(context, message: results["message"]);
                Navigator.pop(context);
              } else {
                Commons.showError(context, results["message"]);
              }


            }else{
              Commons.showToast(context, message: "عفوا يجب عليك تسجيل الدخول اولا");
            }


          },
        ),


       Text("|"),
        Padding(padding: EdgeInsets.all(5)),

        GestureDetector(
          child: Text(_homeProvider.currentLang=="ar"?"تقييم البائع":"Rate user",style: TextStyle(color: mainAppColor,fontSize: 17),),
          onTap: () async{



            if(_authProvider.currentUser!=null){


              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(10),

                                child: Column(
                                  children: <Widget>[
                                    CheckboxListTile(
                                      checkColor: Colors.white,
                                      activeColor: mainAppColor,
                                      title: Text("أتعهد وأقسم بالله أنني قمت بشراء سلعة من العضو "+_homeProvider.currentSellerName+"وأن المعلومات التي أقدمها هي معلومات صحيحة ودقيقة وأتحمل مسؤولية صحة هذه المعلومات ",style: TextStyle(fontSize: 17),),
                                      value: checkedValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          checkedValue = newValue;
                                          _homeProvider.setCheckedValue(newValue.toString());
                                          print(_homeProvider.checkedValue);
                                        });
                                      },
                                    ),
                                    SizedBox(height: 10,),
                                    Text("هل تنصح الأعضاء الآخرين بالتعامل مع البائع "+_homeProvider.currentSellerName,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                    SizedBox(height: 10,),
                                    Column(
                                      children:
                                      fList.map((data) => RadioListTile(
                                        activeColor: mainAppColor,
                                        title: Text("${data.name}"),
                                        groupValue: id,
                                        value: data.index,
                                        onChanged: (val) {
                                          setState(() {
                                            radioItem = data.name ;
                                            id = data.index;

                                            _homeProvider.setCheckedValue1(id.toString());
                                            print(_homeProvider.checkedValue1);

                                          });
                                        },
                                      )).toList(),
                                    ),

                                  ],
                                ),



                              ),

                              CustomButton(
                                btnLbl: "تقييم",
                                borderColor: mainAppColor,
                                onPressedFunction: () async{




                                  final results = await _apiProvider
                                      .post("https://qatar-gates.com/api/rate" +
                                      "?api_lang=${_authProvider.currentLang}", body: {
                                    "rate_user": _authProvider.currentUser.userId,
                                    "rate_user1":_homeProvider.currentSeller,
                                    "rate_value":_homeProvider.checkedValue1!=null?_homeProvider.checkedValue1:1
                                  });


                                  if (results['response'] == "1") {
                                    Commons.showToast(context, message: results["message"]);
                                    Navigator.pop(context);
                                  } else {
                                    Commons.showError(context, results["message"]);
                                  }




                                },
                              )

                            ],
                          );
                        });
                  });


            }else{
              Commons.showToast(context, message: "عفوا يجب عليك تسجيل الدخول اولا");
            }

          },
        ),



      ],

    ),


    



    Container(
      height: 20,
    ),

      Padding(padding: EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(_homeProvider.currentLang=='ar'?"اعلانات المستخدم":"User ads",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        ),
      ),



              Container(
          height: _height - 80,
          width: _width,
          child: FutureBuilder<List<Ad>>(
                  future:  Provider.of<SellerAdsProvider>(context,
                          listen: false)
                      .getAdsList(widget.userId) ,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.active:
                        return Text('');
                      case ConnectionState.waiting:
                        return Center(
                          child: SpinKitFadingCircle(color: mainAppColor),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Error(
                              errorMessage: snapshot.error.toString(),
                           // errorMessage: "حدث خطأ ما ",
                          );
                        } else {
                          if (snapshot.data.length > 0) {
                     return     ListView.builder(
            itemCount: snapshot.data.length,
             itemBuilder: (BuildContext context, int index) {
               var count = snapshot.data.length;
                      var animation = Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      );
                      _animationController.forward();
               return Container(
                 height: _height*.20,
                 width: _width,
                 child: InkWell(
                   onTap: (){

                     _homeProvider.setCurrentAds(snapshot
                         .data[index].adsId);


                      Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdDetailsScreen(
                                  ad: snapshot.data[index],


                                )));
                   },
                   child: AdItem(
                     animationController: _animationController,
                     animation: animation,
                     ad: snapshot.data[index],
                   )));
             }
          );
                          } else {
                            return NoData(message: AppLocalizations.of(context).translate('no_results'));
                          }
                        }
                    }
                    return Center(
                      child: SpinKitFadingCircle(color: mainAppColor),
                    );
                  }),
        )
    ],
  );
}

@override
  Widget build(BuildContext context) {
    _height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    _homeProvider = Provider.of<HomeProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    return PageContainer(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          _buildBodyItem(),
          Container(
              height: 60,
              decoration: BoxDecoration(
                color: mainAppColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Consumer<AuthProvider>(
                      builder: (context,authProvider,child){
                        return authProvider.currentLang == 'ar' ? Image.asset(
                          'assets/images/back.png',
                          color: Colors.white,
                        ): Transform.rotate(
                            angle: 180 * math.pi / 180,
                            child:  Image.asset(
                              'assets/images/back.png',
                              color: Colors.white,
                            ));
                      },
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(
                    flex: 2,
                  ),
                  Text( _homeProvider.currentLang=='ar'?"صاحب الاعلان":"Ads owner",
                      style: Theme.of(context).textTheme.headline1),
                  Spacer(
                    flex: 3,
                  ),
                ],
              )),


        ],
      )),
    );
  }
}