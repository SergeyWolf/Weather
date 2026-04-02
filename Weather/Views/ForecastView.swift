//
//  ForecastView.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var viewModel: WeatherDetailViewModel
    @State private var selectedTab = 0
    @Environment(\.presentationMode) var presentationMode
    
    init(cityWeather: CityWeather) {
        _viewModel = StateObject(wrappedValue: WeatherDetailViewModel(cityWeather: cityWeather))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Назад")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Text(viewModel.cityName)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 12)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    CurrentWeatherView(viewModel: viewModel)
                    WeatherDetailsGrid(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Picker("Тип прогноза", selection: $selectedTab) {
                        Text("3 дня").tag(0)
                        Text("Почасовой").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if selectedTab == 0 {
                        Forecast3DaysView(viewModel: viewModel)
                    } else {
                        if viewModel.hourlyForecast.isEmpty {
                            Text("Нет данных почасового прогноза")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            HourlyForecastScrollView(hourlyForecast: viewModel.hourlyForecast)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarHidden(true)
    }
}

struct Forecast3DaysView: View {
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Прогноз на 3 дня")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.forecast) { day in
                DailyForecastRow(forecast: day, viewModel: viewModel)
            }
        }
    }
}

struct CurrentWeatherView: View {
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: viewModel.largeWeatherIconURL(for: viewModel.currentWeather.weatherIcon)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 100, height: 100)
                }
            }
            
            Text(viewModel.formattedTemperature(viewModel.currentWeather.temperature))
                .font(.system(size: 48, weight: .thin))
            
            Text(viewModel.currentWeather.weatherDescription.capitalized)
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
    }
}
