//
//  CurrentLocationView.swift
//  Weather
//
//  Created by Сергей on 02.04.2026.
//

import SwiftUI

struct CurrentLocationView: View {
    @StateObject private var viewModel = CurrentLocationViewModel()
    @State private var navigateToWeather = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    if viewModel.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text(viewModel.usingDefaultCity ? "Загружаем Москву..." : "Определяем ваше местоположение...")
                                .foregroundColor(.secondary)
                        }
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            if viewModel.locationPermissionDenied {
                                VStack(spacing: 15) {
                                    Button("Открыть настройки") {
                                        viewModel.openSettings()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    
                                    Button("Попробовать снова") {
                                        viewModel.requestLocationAgain()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                Button("Попробовать снова") {
                                    viewModel.checkLocationPermission()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    } else if let cityWeather = viewModel.cityWeather {
                        // Кликабельная карточка погоды
                        NavigationLink(destination: ForecastView(cityWeather: cityWeather)) {
                            VStack(spacing: 20) {
                                HStack(spacing: 8) {
                                    Text(cityWeather.cityName)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    if viewModel.usingDefaultCity {
                                        Image(systemName: "location.slash")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                    } else {
                                        Image(systemName: "location.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(cityWeather.current.weatherIcon)@4x.png")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                    } else if phase.error != nil {
                                        Image(systemName: "cloud.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 120, height: 120)
                                
                                Text(cityWeather.current.temperatureString)
                                    .font(.system(size: 64, weight: .thin))
                                    .foregroundColor(.primary)
                                
                                Text(cityWeather.current.weatherDescription.capitalized)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                if viewModel.usingDefaultCity {
                                    Text("Используется город по умолчанию, так как доступ к геопозиции запрещен")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(radius: 10)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: WeatherListView()) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Все города")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.checkLocationPermission()
        }
    }
}
