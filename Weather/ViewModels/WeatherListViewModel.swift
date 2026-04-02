//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation
import SwiftUI

@MainActor
class WeatherListViewModel: ObservableObject {
    @Published var citiesWeather: [CityWeather] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loadingCities: Set<String> = []
    
    private let repository: WeatherRepositoryProtocol
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }
    
    func loadWeather(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let result = await repository.getWeatherForAllCities()
        
        self.citiesWeather = result
        self.isLoading = false
        
        if result.isEmpty {
            self.errorMessage = "Не удалось загрузить данные о погоде"
        }
    }
    
    func refreshCity(_ cityName: String) async {
        guard let city = APIConstants.cities.first(where: { $0.name == cityName }),
              let index = citiesWeather.firstIndex(where: { $0.cityName == cityName }) else {
            return
        }
        
        loadingCities.insert(cityName)
        
        if let updatedWeather = await repository.getWeatherForCity(city) {
            citiesWeather[index] = updatedWeather
        }
        
        loadingCities.remove(cityName)
    }
    
    func refreshAllCities() async {
        await loadWeather(forceRefresh: true)
    }
    
    func isCityLoading(_ cityName: String) -> Bool {
        loadingCities.contains(cityName)
    }
}
