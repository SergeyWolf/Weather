//
//  WeatherService.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchForecast(for city: APIConstants.City) async throws -> Data
}

class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchForecast(for city: APIConstants.City) async throws -> Data {
        guard let url = APIConstants.Endpoint.forecast(lat: city.lat, lon: city.lon).url else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw WeatherError.unauthorized
            } else if httpResponse.statusCode == 429 {
                throw WeatherError.rateLimit
            } else {
                throw WeatherError.serverError(httpResponse.statusCode)
            }
        }
        
        return data
    }
}

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimit
    case serverError(Int)
    case parsingFailed
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .unauthorized:
            return "Ошибка авторизации. Проверьте API ключ"
        case .rateLimit:
            return "Превышен лимит запросов"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .parsingFailed:
            return "Ошибка парсинга данных"
        case .noData:
            return "Нет данных"
        }
    }
}
