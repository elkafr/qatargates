import 'package:flutter/material.dart';
import 'package:qatargates/models/ad.dart';
import 'package:qatargates/models/user.dart';
import 'package:qatargates/networking/api_provider.dart';
import 'package:qatargates/providers/auth_provider.dart';
import 'package:qatargates/utils/urls.dart';

class SectionAdsProvider extends ChangeNotifier{

  String _currentLang;

  void update(AuthProvider authProvider) {
 
    _currentLang =  authProvider.currentLang;
  }
ApiProvider _apiProvider = ApiProvider();
    Future<List<Ad>> getAdsList(String catId) async {
    final response = await _apiProvider.get(
      Urls.ADS_SECTION_URL + "cat_id=$catId&api_lang=$_currentLang"
      );
        List<Ad> adsList = List<Ad>();
    if (response['response'] == '1') {
      Iterable iterable = response['results'];
      adsList = iterable.map((model) => Ad.fromJson(model)).toList();
    }
    return adsList;
  }
}