//
//  LocationService.swift
//  Weather
//
//  Created by Сергей on 02.04.2026.
//

import Foundation
import CoreLocation
import Combine

enum LocationError: LocalizedError {
    case unauthorized
    case denied
    case restricted
    case unableToDetermine
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Не удалось получить доступ к геопозиции"
        case .denied:
            return "Доступ к геопозиции запрещен. Разрешите доступ в настройках"
        case .restricted:
            return "Доступ к геопозиции ограничен"
        case .unableToDetermine:
            return "Не удалось определить местоположение"
        case .networkError:
            return "Ошибка сети при определении города"
        }
    }
}

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published var currentCity: String?
    @Published var error: LocationError?
    @Published var isLoading = false
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func getCityName(from location: CLLocation) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let city = placemark.locality ?? placemark.administrativeArea else {
                    continuation.resume(throwing: LocationError.unableToDetermine)
                    return
                }
                
                continuation.resume(returning: city)
            }
        }
    }
    
    func updateLocationAndCity() async {
        isLoading = true
        error = nil
        
        do {
            let location = try await getCurrentLocation()
            self.lastLocation = location
            
            let city = try await getCityName(from: location)
            self.currentCity = city
            
        } catch let locationError as LocationError {
            self.error = locationError
        } catch let clError as CLError {
            switch clError.code {
            case .denied:
                self.error = .denied
            case .network:
                self.error = .networkError
            default:
                self.error = .unableToDetermine
            }
        } catch {
            self.error = .unableToDetermine
        }
        
        isLoading = false
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        authorizationStatus = newStatus
        
        switch newStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            error = nil
            Task {
                await updateLocationAndCity()
            }
        case .denied:
            error = .denied
            currentCity = nil
        case .restricted:
            error = .restricted
            currentCity = nil
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        continuation?.resume(returning: location)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
