//
//  Weather.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation
import SwiftUI

struct Weather: Identifiable, Equatable {
    let id = UUID()
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
    let visibility: Double
    let windSpeed: Double
    let cloudiness: Double
    let weatherDescription: String
    let weatherIcon: String
    let timestamp: Date
    
    var temperatureString: String {
        String(format: "%.1f°C", temperature)
    }
    
    var isCold: Bool {
        temperature < 10
    }
    
    var backgroundColor: Color {
        if temperature < 0 {
            return Color.blue.opacity(0.3)
        } else if temperature < 10 {
            return Color.cyan.opacity(0.2)
        } else if temperature < 20 {
            return Color.green.opacity(0.2)
        } else if temperature < 30 {
            return Color.orange.opacity(0.2)
        } else {
            return Color.red.opacity(0.2)
        }
    }
}
