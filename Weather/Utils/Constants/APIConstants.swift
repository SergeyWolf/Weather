//
//  APIConstants.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

enum APIConstants {
    static let apiKey = "0b3691ded8285e4bf157ad3e9b6b43cd"
    
    static let cities: [City] = [
        City(name: "Лондон", lat: 51.5074, lon: -0.1278),
        City(name: "Париж", lat: 48.8566, lon: 2.3522),
        City(name: "Нью-Йорк", lat: 40.7128, lon: -74.0060),
        City(name: "Рим", lat: 41.9028, lon: 12.4964),
        City(name: "Москва", lat: 55.7558, lon: 37.6173)
    ]
    
    struct City {
        let name: String
        let lat: Double
        let lon: Double
    }
    
    enum Endpoint {
        case forecast(lat: Double, lon: Double)
        
        var url: URL? {
            switch self {
            case .forecast(let lat, let lon):
                return URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&lang=ru&appid=\(apiKey)")
            }
        }
    }
}
