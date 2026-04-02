//
//  CityWeather.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//


import Foundation

struct CityWeather: Identifiable {
    let id = UUID()
    let cityName: String
    let current: Weather
    let forecast: [DailyForecast]
    let hourlyForecast: [HourlyForecast]
}
