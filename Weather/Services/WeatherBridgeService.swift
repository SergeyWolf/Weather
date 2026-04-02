//
//  WeatherBridgeService.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//


import Foundation

protocol WeatherBridgeProtocol {
    func parseForecastJSON(_ jsonString: String, for cityName: String) -> CityWeather?
}

class WeatherBridgeService: WeatherBridgeProtocol {
    
    func parseForecastJSON(_ jsonString: String, for cityName: String) -> CityWeather? {
        print("WeatherBridgeService: Начинаем парсинг для \(cityName)")
        
        var success: Int32 = 0
        
        guard let cWeather = jsonString.withCString({ jsonPtr in
            cityName.withCString { cityPtr in
                parse_forecast_json(jsonPtr, cityPtr, &success)
            }
        }), success == 1 else {
            print("C++ парсер не смог обработать данные для \(cityName), success = \(success)")
            return nil
        }
        
        print("C++ парсер успешно обработал данные для \(cityName)")
        
        defer { free_weather_data(cWeather) }
        
        let result = CityWeather(from: cWeather.pointee)
        print("Конвертация в Swift завершена для \(cityName)")
        
        return result
    }
}
