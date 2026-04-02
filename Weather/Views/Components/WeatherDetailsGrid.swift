//
//  WeatherDetailsGrid.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import SwiftUI

struct WeatherDetailsGrid: View {
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            DetailItem(
                icon: "thermometer",
                title: "Ощущается",
                value: viewModel.formattedTemperature(viewModel.currentWeather.feelsLike)
            )
            
            DetailItem(
                icon: "wind",
                title: "Ветер",
                value: viewModel.formattedWindSpeed(viewModel.currentWeather.windSpeed)
            )
            
            DetailItem(
                icon: "gauge",
                title: "Давление",
                value: viewModel.formattedPressure(viewModel.currentWeather.pressure)
            )
            
            DetailItem(
                icon: "humidity",
                title: "Влажность",
                value: viewModel.formattedHumidity(viewModel.currentWeather.humidity)
            )
            
            DetailItem(
                icon: "eye",
                title: "Видимость",
                value: viewModel.formattedVisibility(viewModel.currentWeather.visibility)
            )
            
            DetailItem(
                icon: "cloud",
                title: "Облачность",
                value: viewModel.formattedHumidity(viewModel.currentWeather.cloudiness)
            )
        }
    }
}
