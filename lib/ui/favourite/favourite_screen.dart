import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qatargates/custom_widgets/ad_item/ad_item.dart';
import 'package:qatargates/custom_widgets/no_data/no_data.dart';
import 'package:qatargates/custom_widgets/safe_area/page_container.dart';
import 'package:qatargates/locale/app_localizations.dart';

import 'package:qatargates/models/ad.dart';
import 'package:qatargates/providers/favourite_provider.dart';

import 'package:qatargates/providers/home_provider.dart';
import 'package:qatargates/ui/ad_details/ad_details_screen.dart';

import 'package:qatargates/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:qatargates/utils/error.dart';
class FavouriteScreen extends StatefulWidget {
  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
  with TickerProviderStateMixin{
double _height = 0 , _width = 0;
HomeProvider _homeProvider;
  AnimationController _animationController;

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
  return Column(
    children: <Widget>[
         SizedBox(
            height: 70,
          ),
              Container(
          height: _height - 150,
          width: _width,
          child:FutureBuilder<List<Ad>>(
                  future:  Provider.of<FavouriteProvider>(context,
                          listen: true)
                      .getFavouriteAdsList(),
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
                            //  errorMessage: snapshot.error.toString(),
                            errorMessage: AppLocalizations.of(context).translate('error'),
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
                height: 145,
                                        width: _width,
                 child: InkWell(
                   onTap: (){

                     _homeProvider.setCurrentAds(snapshot
                         .data[index].adsId);

                       Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AdDetailsScreen(
                                                            ad: snapshot
                                                                .data[index],
                                                          )));
                   },
                   child: AdItem(
                     insideFavScreen: true,
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
                  })
        
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
    return PageContainer(
      child:  WillPopScope(
          onWillPop: () async {



            // This dialog will exit your app on saying yes
            return (await showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text(_homeProvider.currentLang=="ar"?'هل انت متاكد ؟':'are you sure ?'),
                content: new Text(_homeProvider.currentLang=="ar"?'هل تريد بالفعل الخروج من التطبيق ؟':'Do you really want to exit the application?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text(_homeProvider.currentLang=="ar"?'لا':'no'),
                  ),
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: new Text(_homeProvider.currentLang=="ar"?'نعم':'yes'),
                  ),
                ],
              ),
            )) ??
                false;
          },
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
                    child: Center(
                      child: Text(AppLocalizations.of(context).translate('favourite'),
                          style: Theme.of(context).textTheme.headline1),
                    ),
                  )
                ],
              ))),
    );
  }
}