//
//  WeatherRowView.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import SwiftUI

struct WeatherRowView: View {
    let weather: Weather
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.weatherIcon)@2x.png")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.cityName)
                    .font(.headline)
                
                Text(weather.weatherDescription.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(weather.temperatureString)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(weather.isCold ? .blue : .primary)
            
            // Кнопка обновления
            Button(action: onRefresh) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .disabled(isLoading)
            .buttonStyle(BorderlessButtonStyle())
            .padding(.leading, 8)
        }
        .padding()
        .background(weather.backgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
