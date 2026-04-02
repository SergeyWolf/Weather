//
//  weather_bridge.cpp
//  Weather
//
//  Created by Сергей on 12.02.2026.
//


#include "weather_bridge.h"
#include "WeatherParser.h"
#include <cstring>
#include <vector>
#include <iostream>

using namespace std;

extern "C" struct CityWeatherC* parse_weather_json(const char* json_str, const char* city_name, int* success) {
    if (!json_str || !city_name || !success) {
        if (success) *success = 0;
        return nullptr;
    }
    
    try {
        WeatherParser parser;
        CityWeather weather = parser.parseCurrentWeather(string(json_str), string(city_name));
        
        CityWeatherC* result = new CityWeatherC();
        memset(result, 0, sizeof(CityWeatherC));
        
        strncpy(result->cityName, weather.cityName.c_str(), sizeof(result->cityName) - 1);
        result->cityName[sizeof(result->cityName) - 1] = '\0';
        result->current = weather.current;
        
        *success = 1;
        return result;
        
    } catch (const exception& e) {
        cout << "C++: Ошибка в parse_weather_json: " << e.what() << endl;
        *success = 0;
        return nullptr;
    } catch (...) {
        cout << "C++: Неизвестная ошибка в parse_weather_json" << endl;
        *success = 0;
        return nullptr;
    }
}

extern "C" struct CityWeatherC* parse_forecast_json(const char* json_str, const char* city_name, int* success) {
    if (!json_str || !city_name || !success) {
        if (success) *success = 0;
        return nullptr;
    }
    
    try {
        WeatherParser parser;
        CityWeather weather = parser.parseOneCallAPI(string(json_str), string(city_name));
        
        CityWeatherC* result = new CityWeatherC();
        memset(result, 0, sizeof(CityWeatherC));
        
        strncpy(result->cityName, weather.cityName.c_str(), sizeof(result->cityName) - 1);
        result->cityName[sizeof(result->cityName) - 1] = '\0';
        result->current = weather.current;
        
        // Копируем дневной прогноз (до 7 дней)
        size_t forecastCount = min(weather.forecast.size(), size_t(7));
        for (size_t i = 0; i < forecastCount; i++) {
            result->forecast[i] = weather.forecast[i];
        }
        
        // Копируем почасовой прогноз (до 40 записей)
        size_t hourlyCount = min(weather.hourly.size(), size_t(40));
        result->hourlyCount = static_cast<int>(hourlyCount);
        for (size_t i = 0; i < hourlyCount; i++) {
            result->hourly[i] = weather.hourly[i];
        }
        
        *success = 1;
        return result;
        
    } catch (const exception& e) {
        cout << "C++: Ошибка в parse_forecast_json: " << e.what() << endl;
        *success = 0;
        return nullptr;
    } catch (...) {
        cout << "C++: Неизвестная ошибка в parse_forecast_json" << endl;
        *success = 0;
        return nullptr;
    }
}

extern "C" void free_weather_data(struct CityWeatherC* data) {
    delete data;
}
