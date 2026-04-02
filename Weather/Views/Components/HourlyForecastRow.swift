//
//  HourlyForecastRow.swift
//  Weather
//
//  Created by Сергей on 02.04.2026.
//

import SwiftUI

struct HourlyForecastRow: View {
    let forecast: HourlyForecast
    
    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.timeString)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(height: 40)
            
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(forecast.weatherIcon).png")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 40, height: 40)
            
            Text(forecast.temperatureString)
                .font(.headline)
                .fontWeight(.medium)
            
            Text("\(Int(forecast.humidity))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(width: 80)
    }
}

struct HourlyForecastScrollView: View {
    let hourlyForecast: [HourlyForecast]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Почасовой прогноз (каждые 3 часа)")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hourlyForecast) { hour in
                        HourlyForecastRow(forecast: hour)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
