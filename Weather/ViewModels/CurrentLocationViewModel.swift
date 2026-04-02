//
//  CurrentLocationViewModel.swift
//  Weather
//
//  Created by Сергей on 02.04.2026.
//

import Foundation
import SwiftUI

@MainActor
class CurrentLocationViewModel: ObservableObject {
    @Published var cityWeather: CityWeather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locationPermissionDenied = false
    @Published var usingDefaultCity = false
    
    private let locationService = LocationService.shared
    private let repository: WeatherRepositoryProtocol
    private let defaultCity = APIConstants.City(name: "Москва", lat: 55.7558, lon: 37.6173)
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
        setupObservers()
    }
    
    private func setupObservers() {
        Task {
            for await status in locationService.$authorizationStatus.values {
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    locationPermissionDenied = false
                    await locationService.updateLocationAndCity()
                case .denied, .restricted:
                    locationPermissionDenied = true
                    await loadDefaultCity()
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        Task {
            for await city in locationService.$currentCity.values {
                if let city = city, !city.isEmpty {
                    usingDefaultCity = false
                    await fetchWeather(for: city)
                }
            }
        }
    }
    
    func checkLocationPermission() {
        let status = locationService.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationService.requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionDenied = false
            Task {
                await locationService.updateLocationAndCity()
            }
        case .denied, .restricted:
            locationPermissionDenied = true
            Task {
                await loadDefaultCity()
            }
        @unknown default:
            break
        }
    }
    
    func loadDefaultCity() async {
        print("Загружаем город по умолчанию: Москва")
        usingDefaultCity = true
        errorMessage = nil
        isLoading = true
        
        cityWeather = await repository.getWeatherForCity(defaultCity)
        
        isLoading = false
        
        if cityWeather == nil {
            errorMessage = "Не удалось загрузить данные о погоде для Москвы. Проверьте интернет-соединение."
            print("Ошибка загрузки Москвы")
        } else {
            print("Москва успешно загружена")
        }
    }
    
    func fetchWeather(for cityName: String) async {
        isLoading = true
        errorMessage = nil
        
        if let city = APIConstants.cities.first(where: { $0.name.lowercased() == cityName.lowercased() }) {
            cityWeather = await repository.getWeatherForCity(city)
        } else {
            do {
                let coordinates = try await getCoordinates(for: cityName)
                let city = APIConstants.City(name: cityName, lat: coordinates.lat, lon: coordinates.lon)
                cityWeather = await repository.getWeatherForCity(city)
            } catch {
                errorMessage = "Город \(cityName) не найден. Показываем Москву"
                await loadDefaultCity()
            }
        }
        
        isLoading = false
        
        if cityWeather == nil && errorMessage == nil {
            errorMessage = "Не удалось загрузить данные о погоде. Проверьте интернет-соединение."
            await loadDefaultCity()
        }
    }
    
    private func getCoordinates(for cityName: String) async throws -> (lat: Double, lon: Double) {
        let encodedCity = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(encodedCity)&limit=1&appid=\(APIConstants.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw LocationError.unableToDetermine
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct GeocodingResponse: Codable {
            let lat: Double
            let lon: Double
        }
        
        let results = try JSONDecoder().decode([GeocodingResponse].self, from: data)
        
        guard let first = results.first else {
            throw LocationError.unableToDetermine
        }
        
        return (first.lat, first.lon)
    }
    
    func requestLocationAgain() {
        locationPermissionDenied = false
        errorMessage = nil
        usingDefaultCity = false
        checkLocationPermission()
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
