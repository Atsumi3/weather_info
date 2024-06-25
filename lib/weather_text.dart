import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';

import 'weather_data.dart';

/// 天気情報を表示するウィジェット
class WeatherText extends StatefulWidget {
  const WeatherText({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherText> {
  /// OpenWeatherMapのAPIキー
  static const String _apiKey = "YOUR_OPEN_WEATHER_MAP_API_KEY";

  /// 位置情報を取得するためのインスタンス
  final _location = Location();

  /// 取得した天気のデータ
  WeatherData? _weatherData;

  /// エラーメッセージ
  String? _errorMessage;

  /// 現在の位置情報
  LocationData? _locationData;

  Future<void> _initLocation() async {
    /// 使っている端末で位置情報サービスを利用できるかのチェック
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      /// 位置情報サービスが利用できない場合は、位置情報サービスを有効にするように促す
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        /// 位置情報サービスが利用できない場合は、何もしない
        _errorMessage = "位置情報サービスは利用できません";
        return;
      }
    }

    /// 位置情報にアクセスするための権限を取得
    var permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      /// 位置情報にアクセスするための権限がない場合は、権限を取得するように促す
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        /// 位置情報にアクセスするための権限がない場合は、何もしない
        _errorMessage = "位置情報にアクセスするための権限がありません";
        return;
      }
    }
  }

  @override
  void initState() {
    /// 画面が描画された後に位置情報を取得する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 位置情報を取得する
      _initLocation();
    });

    /// 位置情報が変更された場合に天気情報を取得する
    _location.onLocationChanged.listen((currentLocation) {
      if (_locationData == null) {
        /// 位置情報が取得できていない場合は、位置情報を取得する
        _location.getLocation().then((currentLocation) {
          _locationData = currentLocation;

          /// 天気情報を取得する
          _fetchWeather(currentLocation);
        });
      }
    });
    super.initState();
  }

  /// 天気情報を取得する
  Future<void> _fetchWeather(LocationData data) async {
    /// 天気情報を取得するためのURL
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=${data.latitude}&lon=${data.longitude}&appid=$_apiKey";

    /// 天気情報を取得する
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        /// 取得した天気情報をセットする
        _weatherData = WeatherData.fromJson(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      /// エラーメッセージがある場合は、エラーメッセージを表示する
      return Text(_errorMessage!);
    }

    final data = _weatherData;
    if (data == null) {
      /// 天気情報が取得できていない場合は、ローディングを表示する
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Loading..."),
        ],
      );
    }

    /// 天気情報が取得できている場合は、天気情報を表示する
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Location: ${data.name}"),
        Text("Temperature: ${data.tempCelcius.toStringAsFixed(1)}°C"),
        Text("Pressure: ${data.pressure}hPa"),
        Text("Wind: ${data.windSpeed}m/s ${data.windDeg}°"),
        Text("Description: ${data.description}"),
      ],
    );
  }
}
