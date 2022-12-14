import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qatargates/custom_widgets/buttons/custom_button.dart';
import 'package:qatargates/custom_widgets/custom_text_form_field/custom_text_form_field.dart';
import 'package:qatargates/custom_widgets/custom_text_form_field/validation_mixin.dart';
import 'package:qatargates/custom_widgets/safe_area/page_container.dart';
import 'package:qatargates/locale/app_localizations.dart';
import 'package:qatargates/models/user.dart';
import 'package:qatargates/networking/api_provider.dart';
import 'package:qatargates/providers/auth_provider.dart';
import 'package:qatargates/providers/home_provider.dart';
import 'package:qatargates/utils/app_colors.dart';
import 'package:qatargates/utils/commons.dart';
import 'package:qatargates/utils/urls.dart';
import 'package:qatargates/shared_preferences/shared_preferences_helper.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class ActiveAccountScreen extends StatefulWidget {
  @override
  _ActiveAccountScreenState createState() => _ActiveAccountScreenState();
}

class _ActiveAccountScreenState extends State<ActiveAccountScreen>
    with ValidationMixin {
  double _height = 0, _width = 0;
  bool _isLoading = false;
  String _activationCode = '';
  ApiProvider _apiProvider = ApiProvider();
  AuthProvider _authProvider;
  HomeProvider _homeProvider;
  final _formKey = GlobalKey<FormState>();

  Widget _buildBodyItem() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: _height * 0.05),
              child: Image.asset(
                ' assets/images/full_reset.png',
                height: _height * 0.2,
              ),
            ),
            Text(
             _homeProvider.currentLang=="ar"?"?????? ?????????? ????????????":"Active Account COde",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(bottom: _height * 0.02),
              child: Text(
                
              _homeProvider.currentLang=="ar"?"???????? ?????????? ???????????? ?????? ?????????? ???????????? ????????????":"Enter the code sent on your phone to activate the account",
                style: TextStyle(color: Color(0xffC5C5C5), fontSize: 14),
              ),
            ),
            CustomTextFormField(
              prefixIconIsImage: true,
              prefixIconImagePath: 'assets/images/edit.png',
              hintTxt:  AppLocalizations.of(context).translate('code_here'),
              inputData: TextInputType.number,
              onChangedFunc: (text) {
                _activationCode = text;
              },
              validationFunc: validateActivationCode,
            ),
            SizedBox(
              height: _height * 0.01,
            ),
            _buildRecoveryBtn(),

          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryBtn() {
    return  CustomButton(
            btnLbl: _homeProvider.currentLang=="ar"?"??????????":"Active",
            onPressedFunction: () async {
              if (_formKey.currentState.validate()) {
                setState(() {
                  _isLoading = true;
                });
                final results =
                    await _apiProvider.post("https://qatar-gates.com/api/active_code?lang=${_authProvider.currentLang}", body: {
                  "user_code": _activationCode,
                  "user_id": _authProvider.currentUser.userId,
                });

                setState(() => _isLoading = false);
                if (results['response'] == "1") {
                  _authProvider.setCurrentUser(User.fromJson(results["user_details"]));
                  SharedPreferencesHelper.save("user", _authProvider.currentUser);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/navigation', (Route<dynamic> route) => false);
                } else {
                  Commons.showError(context, results["message"]);
                }
              }
            },
          );
  }



  @override
  Widget build(BuildContext context) {
    _height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    _width = MediaQuery.of(context).size.width;
    _authProvider = Provider.of<AuthProvider>(context);
    _homeProvider = Provider.of<HomeProvider>(context);
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
                    flex: 1,
                  ),
                  Text(_homeProvider.currentLang=="ar"?"?????????? ????????????":"Active account",
                      style: Theme.of(context).textTheme.headline1),
                  Spacer(
                    flex: 2,
                  ),
                ],
              )),
        _isLoading
        ? Center(
            child: SpinKitFadingCircle(color: mainAppColor),
          )
        :Container()
        ],
      )),
    );
  }
}
