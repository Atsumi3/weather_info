/// 天気情報を表すクラス
class WeatherData {
  final double windSpeed;
  final int windDeg;
  final double temp;
  final int pressure;
  final String description;
  final String name;

  WeatherData({
    required this.windSpeed,
    required this.windDeg,
    required this.temp,
    required this.pressure,
    required this.description,
    required this.name,
  });

  /// 摂氏温度を取得する
  double get tempCelcius => temp - 273.15;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      windSpeed: json["wind"]["speed"],
      windDeg: json["wind"]["deg"],
      temp: json["main"]["temp"],
      pressure: json["main"]["pressure"],
      description: json["weather"][0]["description"],
      name: json["name"],
    );
  }
}
