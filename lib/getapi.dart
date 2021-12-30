import 'package:wateringsystem/cubit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GetApi {
  String ip = 'http://192.168.0.207:5000';
  get getIp => ip;
  set setIp(String value) => ip = value;

  GetApi();

  Future<int> predict() async {
    var moisture = moistureCubit.state;
    var date = DateFormat("hh:mm,dd-MM-yyyy").format(DateTime.now());
    var queryParameters = {
      'soil_moisture': '$moisture',
      'upload_time': '$date',
    };
    var uri = Uri.http(ip, '/predict', queryParameters);
    var response = await http.post(uri);
    if (response.statusCode == 200) {
      String htmlToParse = response.body;
      print(htmlToParse);
      var value = (double.parse(htmlToParse) * 1000).round();
      return value;
    }
    return 0;
  }
}

final GetApi getApi = GetApi();
