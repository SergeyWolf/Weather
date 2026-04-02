//
//  WeatherDetailViewModel.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation
import SwiftUI

@MainActor
class WeatherDetailViewModel: ObservableObject {
    @Published var cityWeather: CityWeather
    
    init(cityWeather: CityWeather) {
        self.cityWeather = cityWeather
    }
    
    var cityName: String {
        cityWeather.cityName
    }
    
    var currentWeather: Weather {
        cityWeather.current
    }
    
    var forecast: [DailyForecast] {
        Array(cityWeather.forecast.prefix(3))
    }
    
    var hourlyForecast: [HourlyForecast] {
        cityWeather.hourlyForecast
    }
    
    func formattedTemperature(_ temp: Double) -> String {
        String(format: "%.1f°C", temp)
    }
    
    func formattedPressure(_ pressure: Double) -> String {
        String(format: "%.0f гПа", pressure)
    }
    
    func formattedHumidity(_ humidity: Double) -> String {
        String(format: "%.0f%%", humidity)
    }
    
    func formattedVisibility(_ visibility: Double) -> String {
        String(format: "%.0f км", visibility / 1000)
    }
    
    func formattedWindSpeed(_ speed: Double) -> String {
        String(format: "%.1f м/с", speed)
    }
    
    func weatherIconURL(for icon: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
    
    func largeWeatherIconURL(for icon: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
    }
}
