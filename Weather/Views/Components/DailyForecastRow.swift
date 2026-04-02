//
//  DailyForecastRow.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import SwiftUI

struct DailyForecastRow: View {
    let forecast: DailyForecast
    let viewModel: WeatherDetailViewModel
    
    var body: some View {
        HStack {
            Text(forecast.dayOfWeek)
                .font(.headline)
                .frame(width: 40, alignment: .leading)
            
            AsyncImage(url: viewModel.weatherIconURL(for: forecast.weatherIcon)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: 30)
            
            Text(forecast.weatherDescription.capitalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(forecast.dayTemperatureString)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(forecast.nightTemperatureString)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct ForecastWeekView: View {
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Прогноз на неделю")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.forecast) { day in
                DailyForecastRow(forecast: day, viewModel: viewModel)
            }
        }
    }
}
