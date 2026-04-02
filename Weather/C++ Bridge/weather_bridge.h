//
//  weather_bridge.h
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

#ifndef weather_bridge_h
#define weather_bridge_h

#ifdef __cplusplus
extern "C" {
#endif

struct CityWeatherC* parse_weather_json(const char* json_str, const char* city_name, int* success);
struct CityWeatherC* parse_forecast_json(const char* json_str, const char* city_name, int* success);
void free_weather_data(struct CityWeatherC* data);

#ifdef __cplusplus
}
#endif

#endif
