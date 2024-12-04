import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0.0;
  double windSpeed = 0.0;
  int humidity = 0;
  String weatherCondition = 'Kondisi_Tidak_Diketahui';
  List<dynamic> forecastData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final latitude = -6.8441;
    final longitude = 107.6381;

    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m'
        '&hourly=weather_code&timezone=Asia%2FJakarta&forecast_days=4');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          temperature = data['current']['temperature_2m'];
          windSpeed = data['current']['wind_speed_10m'];
          humidity = data['current']['relative_humidity_2m'];
          weatherCondition = _mapWeatherCode(data['hourly']['weather_code'][0]);

          forecastData = List.generate(4, (index) {
            return {
              'date': DateTime.now().add(Duration(days: index + 1)),
              'weather_code': data['daily']['weather_code'][index],
              'max_temp': data['daily']['temperature_2m_max'][index],
              'min_temp': data['daily']['temperature_2m_min'][index]
            };
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch weather data. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
    }
  }

  String _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Sebagian_Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      default:
        return 'Kondisi_Tidak_Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cuaca Tahura Bandung',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildWeatherContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Sizes.medium),
        child: Column(
          children: [
            Container(
              height: ScreenUtils.getResponsiveHeight(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusLarge),
              ),
            ),
            SizedBox(height: Sizes.medium),
            Container(
              height: ScreenUtils.getResponsiveHeight(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildCurrentWeatherCard(),
          _buildForecastSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      margin: EdgeInsets.all(Sizes.medium),
      padding: EdgeInsets.all(Sizes.large),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        children: [
          Image.asset(
            'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/$weatherCondition.png',
            width: ScreenUtils.getResponsiveWidth(30),
            height: ScreenUtils.getResponsiveWidth(30),
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.cloud,
                color: Colors.white,
                size: ScreenUtils.getResponsiveWidth(30),
              );
            },
          ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
          SizedBox(height: Sizes.medium),
          Text(
            weatherCondition.replaceAll('_', ' '),
            style: TahuraTextStyles.screenTitle,
          ).animate().fadeIn(duration: TahuraAnimations.medium),
          SizedBox(height: Sizes.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetailItem(
                icon: Icons.thermostat,
                value: '${temperature.toStringAsFixed(1)}°C',
                label: 'Temperatur',
              ),
              _buildWeatherDetailItem(
                icon: Icons.water_drop,
                value: '$humidity%',
                label: 'Kelembapan',
              ),
              _buildWeatherDetailItem(
                icon: Icons.air,
                value: '${windSpeed.toStringAsFixed(1)} km/h',
                label: 'Kecepatan Angin',
              ),
            ],
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }

  Widget _buildWeatherDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: Sizes.iconLarge,
        ),
        SizedBox(height: Sizes.small),
        Text(
          value,
          style: TahuraTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TahuraTextStyles.bodyTextSecondary,
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Container(
      margin: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Sizes.medium),
            child: Text(
              'Prakiraan 4 Hari Kedepan',
              style: TahuraTextStyles.screenTitle,
            ),
          ),
          ...forecastData.asMap().entries.map((entry) {
            final forecast = entry.value;
            final index = entry.key;
            return _buildForecastItem(
              date: forecast['date'],
              condition: _mapWeatherCode(forecast['weather_code']),
              maxTemp: forecast['max_temp'].toString(),
              minTemp: forecast['min_temp'].toString(),
            )
                .animate()
                .fadeIn(
                  duration: TahuraAnimations.medium,
                  delay: Duration(milliseconds: 100 * index),
                )
                .slideX(begin: 0.2, end: 0);
          }).toList(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: TahuraAnimations.medium)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildForecastItem({
    required DateTime date,
    required String condition,
    required String maxTemp,
    required String minTemp,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.medium,
        vertical: Sizes.small,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Image.asset(
          'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/$condition.png',
          width: Sizes.iconXLarge,
          height: Sizes.iconXLarge,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.cloud,
              color: Colors.white,
              size: Sizes.iconXLarge,
            );
          },
        ),
        title: Text(
          DateFormat('EEEE, d MMMM').format(date),
          style: TahuraTextStyles.bodyText,
        ),
        subtitle: Text(
          'Max: $maxTemp°C, Min: $minTemp°C',
          style: TahuraTextStyles.bodyTextSecondary,
        ),
      ),
    );
  }
}
