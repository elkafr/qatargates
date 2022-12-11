import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qatargates/custom_widgets/MainDrawer.dart';
import 'package:qatargates/custom_widgets/custom_text_form_field/custom_text_form_field.dart';
import 'package:qatargates/custom_widgets/custom_text_form_field/custom_text_form_field2.dart';
import 'package:qatargates/models/ad.dart';
import 'package:qatargates/ui/home/widgets/category_item1.dart';
import 'package:qatargates/ui/search/search_screen.dart';
import 'package:qatargates/utils/app_colors.dart';
import 'package:qatargates/utils/app_colors.dart';
import 'package:qatargates/utils/urls.dart';
import 'package:qatargates/custom_widgets/ad_item/ad_item.dart';
import 'package:qatargates/custom_widgets/no_data/no_data.dart';
import 'package:qatargates/custom_widgets/safe_area/page_container.dart';
import 'package:qatargates/locale/app_localizations.dart';
import 'package:qatargates/custom_widgets/MainDrawer.dart';

import 'package:qatargates/models/ad.dart';
import 'package:qatargates/models/category.dart';
import 'package:qatargates/providers/home_provider.dart';
import 'package:qatargates/providers/navigation_provider.dart';
import 'package:qatargates/ui/ad_details/ad_details_screen.dart';
import 'package:qatargates/ui/home/widgets/category_item.dart';
import 'package:qatargates/ui/home/widgets/map_widget.dart';
import 'package:qatargates/ui/search/search_bottom_sheet.dart';
import 'package:qatargates/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:qatargates/utils/error.dart';
import 'package:qatargates/providers/navigation_provider.dart';
import 'package:qatargates/providers/auth_provider.dart';
import 'package:qatargates/ui/home/widgets/slider_images.dart';
import 'package:qatargates/ui/home/widgets/slider_images1.dart';
import 'package:qatargates/ui/home/cats_screen.dart';
import 'package:qatargates/networking/api_provider.dart';
import 'package:qatargates/providers/auth_provider.dart';
import 'package:qatargates/utils/urls.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double _height = 0, _width = 0;
  NavigationProvider _navigationProvider;
 Future<List<CategoryModel>> _categoryList;
  bool _initialRun = true;
  HomeProvider _homeProvider;
  AnimationController _animationController;
  AuthProvider _authProvider;
  Future<List<Ad>> _sacrificesList;
  ApiProvider _apiProvider = ApiProvider();
  String xx='';


  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }
    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialRun) {
      _homeProvider = Provider.of<HomeProvider>(context);
      _categoryList = _homeProvider.getCategoryList1(categoryModel:  CategoryModel(isSelected:false),enableSub: false);
      _initialRun = false;
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Future<List<Ad>> _getSearchResults(String title) async {
    Map<String, dynamic> results =
    await _apiProvider.get(Urls.SEARCH_URL +'title=$title');
    List<Ad> adList = List<Ad>();
    if (results['response'] == '1') {
      Iterable iterable = results['results'];
      adList = iterable.map((model) => Ad.fromJson(model)).toList();
    } else {
      print('error');
    }
    return adList;
  }

  Widget _buildBodyItem() {



    final orientation = MediaQuery.of(context).orientation;
    return ListView(
      children: <Widget>[
        Container(height: 5,),
        SliderImages(),

        Container(
            margin: EdgeInsets.only(right: _width*.06,left:  _width*.04,top:  _width*.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              border: Border.all(
                color: Colors.grey[200],
              ),
              color: Colors.grey[200],

            ),
            height: 35,

            alignment: Alignment.center,

            child: Row(
              children: <Widget>[
                Container(
                  width: _width*.75,

                  child: CustomTextFormField2(

                    hintTxt: _homeProvider.currentLang=="ar"?"رقم الاعلان او عبارة البحث":"Ad number or search term",
                    onChangedFunc: (text) {
                      xx = text;
                    },

                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search,color: mainAppColor,),
                  onPressed: () {
                    _homeProvider.setEnableSearch(true);
                    _homeProvider.setSearchKey(xx);

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchScreen()));

                  },
                )
              ],
            )
        ),

        Container(
          height: _height-270,
          child: FutureBuilder<List<CategoryModel>>(

              future: _categoryList,
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
                        errorMessage: "حدث خطأ ما ",
                      );
                    } else {
                      if (snapshot.data.length > 0) {
                        return GridView.builder(
                          itemCount: snapshot.data.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: (orientation == Orientation.portrait) ? 3 : 3),
                          itemBuilder: (BuildContext context, int index) {
                            return Consumer<HomeProvider>(
                                builder: (context, homeProvider, child) {
                                  return InkWell(
                                    onTap: (){

                                      homeProvider
                                          .updateChangesOnCategoriesList(index);

                                      homeProvider.setEnableSearch(false);

                                      _homeProvider.setSelectedCat(snapshot.data[index]);
                                      print(_homeProvider.selectedCat);

                                      _homeProvider.setCatName(snapshot.data[index].catName);
                                      _homeProvider.setSelectedSub(null);
                                      _homeProvider.setSelectedMarka(null);
                                      _homeProvider.setSelectedModel(null);
                                      _homeProvider.setSelectedCity(null);



                                      _homeProvider.setSelectedCat(snapshot.data[index]);
                                      _homeProvider.setAge(snapshot.data[index].catId);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => CatsScreen(iddd:snapshot.data[index].catId,iddd1:index))
                                      );
                                    },
                                    child: Container(
                                      width: _width * 0.33,
                                      child: CategoryItem1(
                                        category: snapshot.data[index],
                                      ),
                                    ),
                                  );
                                });
                          },
                        );
                      } else {
                        return NoData(message: 'لاتوجد نتائج');
                      }
                    }
                }
                return Center(
                  child: SpinKitFadingCircle(color: mainAppColor),
                );
              }),
        ),





        SliderImages1(),






      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _navigationProvider = Provider.of<NavigationProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    final appBar = AppBar(
      elevation: 0,
      backgroundColor: mainAppColor,
      titleSpacing: 0,
      centerTitle: true,
      title: _authProvider.currentLang == 'ar' ? Text("بوابات قطر",style: TextStyle(fontSize: 17),) :Text("Qatar Gates",style: TextStyle(fontSize: 17)),
      actions: <Widget>[
        GestureDetector(
            onTap: () {
              showModalBottomSheet<dynamic>(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  context: context,
                  builder: (builder) {
                    return Container(
                        width: _width,
                        height: _height * 0.55,
                        child: SearchBottomSheet());
                  });
            },
            child:Image.asset(
              'assets/images/search.png',
              color: Colors.white,
            )),


      ],
    );
    _height = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    _navigationProvider = Provider.of<NavigationProvider>(context);

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

        appBar: PreferredSize(child: appBar,  preferredSize: Size.fromHeight(40.0)),

        drawer: MainDrawer(),
        body: _buildBodyItem(),
      )),
    );
  }
}
