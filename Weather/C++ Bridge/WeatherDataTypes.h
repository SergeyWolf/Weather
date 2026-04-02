//
//  WeatherDataTypes.h
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

#ifndef WeatherDataTypes_h
#define WeatherDataTypes_h

#ifdef __cplusplus
extern "C" {
#endif

struct WeatherC {
    char cityName[64];
    double temperature;
    double feelsLike;
    double pressure;
    double humidity;
    double visibility;
    double windSpeed;
    double cloudiness;
    char weatherDescription[64];
    char weatherIcon[16];
    int timestamp;
};

struct DailyForecastC {
    char cityName[64];
    int timestamp;
    double temperatureDay;
    double temperatureNight;
    double pressure;
    double humidity;
    double visibility;
    double cloudiness;
    char weatherDescription[64];
    char weatherIcon[16];
};

// Новая структура для почасового прогноза
struct HourlyForecastC {
    int timestamp;
    double temperature;
    double feelsLike;
    double humidity;
    double windSpeed;
    char weatherDescription[64];
    char weatherIcon[16];
};

struct CityWeatherC {
    char cityName[64];
    struct WeatherC current;
    struct DailyForecastC forecast[7];
    struct HourlyForecastC hourly[40];
    int hourlyCount;
};

#ifdef __cplusplus
}
#endif

#endif
