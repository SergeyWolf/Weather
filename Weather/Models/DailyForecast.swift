//
//  DailyForecast.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

struct DailyForecast: Identifiable {
    let id = UUID()
    let cityName: String
    let date: Date
    let temperatureDay: Double
    let temperatureNight: Double
    let pressure: Double
    let humidity: Double
    let visibility: Double
    let cloudiness: Double
    let weatherDescription: String
    let weatherIcon: String
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
    
    var dayTemperatureString: String {
        String(format: "%.1f°C", temperatureDay)
    }
    
    var nightTemperatureString: String {
        String(format: "%.1f°C", temperatureNight)
    }
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let feelsLike: Double
    let weatherDescription: String
    let weatherIcon: String
    let humidity: Double
    let windSpeed: Double
    let customTimeString: String
    
    var timeString: String {
        return customTimeString
    }
    
    var temperatureString: String {
        String(format: "%.1f°C", temperature)
    }
    
    init(time: Date, temperature: Double, feelsLike: Double, weatherDescription: String, weatherIcon: String, humidity: Double, windSpeed: Double, customTimeString: String = "") {
        self.time = time
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.humidity = humidity
        self.windSpeed = windSpeed
        
        if customTimeString.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.customTimeString = formatter.string(from: time)
        } else {
            self.customTimeString = customTimeString
        }
    }
}
