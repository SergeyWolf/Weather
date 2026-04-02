//
//  WeatherListView.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import SwiftUI

struct WeatherListView: View {
    @StateObject private var viewModel = WeatherListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
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
                
                Text("Прогноз погоды")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.refreshAllCities()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
            )
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.isLoading && viewModel.citiesWeather.isEmpty {
                        ProgressView("Загрузка погоды...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(viewModel.citiesWeather) { cityWeather in
                            NavigationLink(destination: ForecastView(cityWeather: cityWeather)) {
                                WeatherRowView(
                                    weather: cityWeather.current,
                                    isLoading: viewModel.isCityLoading(cityWeather.cityName),
                                    onRefresh: {
                                        Task {
                                            await viewModel.refreshCity(cityWeather.cityName)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refreshAllCities()
            }
            .overlay {
                if let error = viewModel.errorMessage {
                    ErrorOverlayView(error: error) {
                        Task {
                            await viewModel.refreshAllCities()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadWeather()
        }
    }
}

struct ErrorOverlayView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("\(error)")
                .foregroundColor(.red)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
            
            Button("Повторить") {
                retryAction()
            }
            .padding(.top, 8)
        }
    }
}
