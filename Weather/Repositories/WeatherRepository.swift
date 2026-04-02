//
//  WeatherRepository.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

protocol WeatherRepositoryProtocol {
    func getWeatherForAllCities() async -> [CityWeather]
    func getWeatherForCity(_ city: APIConstants.City) async -> CityWeather?
}

class WeatherRepository: WeatherRepositoryProtocol {
    private let weatherService: WeatherServiceProtocol
    private let weatherBridge: WeatherBridgeProtocol
    private var cache: [String: (weather: CityWeather, timestamp: Date)] = [:]
    private let cacheDuration: TimeInterval = 10 * 60 // 10 минут кэш
    
    init(weatherService: WeatherServiceProtocol = WeatherService(),
         weatherBridge: WeatherBridgeProtocol = WeatherBridgeService()) {
        self.weatherService = weatherService
        self.weatherBridge = weatherBridge
    }
    
    func getWeatherForAllCities() async -> [CityWeather] {
        var results: [CityWeather] = []
        
        await withTaskGroup(of: CityWeather?.self) { group in
            for city in APIConstants.cities {
                group.addTask {
                    await self.getWeatherForCityWithRetry(city, retries: 2)
                }
            }
            
            for await result in group {
                if let weather = result {
                    results.append(weather)
                }
            }
        }
        
        return results.sorted { $0.cityName < $1.cityName }
    }
    
    func getWeatherForCity(_ city: APIConstants.City) async -> CityWeather? {
        return await getWeatherForCityWithRetry(city, retries: 2)
    }
    
    private func getWeatherForCityWithRetry(_ city: APIConstants.City, retries: Int) async -> CityWeather? {
        // Проверяем кэш
        if let cached = cache[city.name], Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            print("Используем кэш для города: \(city.name)")
            return cached.weather
        }
        
        for attempt in 0...retries {
            if attempt > 0 {
                print("Повторная попытка \(attempt) для города: \(city.name)")
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            }
            
            if let weather = await fetchWeatherForCity(city) {
                cache[city.name] = (weather: weather, timestamp: Date())
                return weather
            }
        }
        
        print("Не удалось загрузить данные для города: \(city.name) после \(retries + 1) попыток")
        return nil
    }
    
    private func fetchWeatherForCity(_ city: APIConstants.City) async -> CityWeather? {
        print("Запрос погоды для города: \(city.name)")
        
        do {
            let data = try await weatherService.fetchForecast(for: city)
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Не удалось преобразовать данные в строку для города: \(city.name)")
                return nil
            }
            
            print("Получены данные для \(city.name), длина JSON: \(jsonString.count)")
            
            guard let cityWeather = weatherBridge.parseForecastJSON(jsonString, for: city.name) else {
                print("Не удалось распарсить данные для города: \(city.name)")
                return nil
            }
            
            print("Успешно распарсена погода для города: \(city.name)")
            return cityWeather
            
        } catch {
            print("Ошибка получения погоды для \(city.name): \(error.localizedDescription)")
            return nil
        }
    }
}
