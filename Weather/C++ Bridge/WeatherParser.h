//
//  WeatherParser.h
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

#ifndef WeatherParser_h
#define WeatherParser_h

#include <string>
#include <vector>
#include "WeatherDataTypes.h"

struct CityWeather {
    std::string cityName;
    WeatherC current;
    std::vector<DailyForecastC> forecast;
    std::vector<HourlyForecastC> hourly;
    
    CityWeather() {
        memset(&current, 0, sizeof(WeatherC));
    }
};

class WeatherParser {
public:
    WeatherParser();
    CityWeather parseCurrentWeather(const std::string& jsonString, const std::string& cityName);
    CityWeather parseOneCallAPI(const std::string& jsonString, const std::string& cityName);
};

#endif
