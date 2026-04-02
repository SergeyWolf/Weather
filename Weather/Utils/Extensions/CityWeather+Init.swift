//
//  CityWeather+Init.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

extension CityWeather {
    init(from cStruct: CityWeatherC) {
        // Инициализируем cityName
        let cityName = withUnsafePointer(to: cStruct.cityName) { ptr in
            let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
            return String(cString: charPtr)
        }
        
        let current = Weather(
            cityName: cityName,
            temperature: cStruct.current.temperature,
            feelsLike: cStruct.current.feelsLike,
            pressure: cStruct.current.pressure,
            humidity: cStruct.current.humidity,
            visibility: cStruct.current.visibility,
            windSpeed: cStruct.current.windSpeed,
            cloudiness: cStruct.current.cloudiness,
            weatherDescription: withUnsafePointer(to: cStruct.current.weatherDescription) { ptr in
                let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                return String(cString: charPtr)
            },
            weatherIcon: withUnsafePointer(to: cStruct.current.weatherIcon) { ptr in
                let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                return String(cString: charPtr)
            },
            timestamp: Date(timeIntervalSince1970: TimeInterval(cStruct.current.timestamp))
        )
        
        var forecastArray: [DailyForecast] = []
        
        let forecastPtr = withUnsafePointer(to: cStruct.forecast) { ptr in
            UnsafeRawPointer(ptr).assumingMemoryBound(to: DailyForecastC.self)
        }
        
        for i in 0..<3 {
            let day = forecastPtr[i]
            guard day.timestamp > 0 else { continue }
            
            let weatherDescription = withUnsafePointer(to: day.weatherDescription) { ptr in
                let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                return String(cString: charPtr)
            }
            
            let weatherIcon = withUnsafePointer(to: day.weatherIcon) { ptr in
                let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                return String(cString: charPtr)
            }
            
            let forecast = DailyForecast(
                cityName: cityName,
                date: Date(timeIntervalSince1970: TimeInterval(day.timestamp)),
                temperatureDay: day.temperatureDay,
                temperatureNight: day.temperatureNight,
                pressure: day.pressure,
                humidity: day.humidity,
                visibility: day.visibility,
                cloudiness: day.cloudiness,
                weatherDescription: weatherDescription,
                weatherIcon: weatherIcon
            )
            forecastArray.append(forecast)
        }
        
        var hourlyArray: [HourlyForecast] = []
        let now = Date()
        let calendar = Calendar.current
        
        let hourlyPtr = withUnsafePointer(to: cStruct.hourly) { ptr in
            UnsafeRawPointer(ptr).assumingMemoryBound(to: HourlyForecastC.self)
        }
        
        let count = Int(cStruct.hourlyCount)
        
        print("Всего почасовых записей: \(count)")
        
        for i in 0..<count {
            let hourly = hourlyPtr[i]
            let date = Date(timeIntervalSince1970: TimeInterval(hourly.timestamp))
            
            let isToday = calendar.isDate(date, inSameDayAs: now)
            let isTomorrow = calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
            
            if isToday || isTomorrow {
                let weatherDescription = withUnsafePointer(to: hourly.weatherDescription) { ptr in
                    let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                    return String(cString: charPtr)
                }
                
                let weatherIcon = withUnsafePointer(to: hourly.weatherIcon) { ptr in
                    let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                    return String(cString: charPtr)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                var timeString = formatter.string(from: date)
                
                if isTomorrow {
                    timeString = "Завтра " + timeString
                }
                
                let forecast = HourlyForecast(
                    time: date,
                    temperature: hourly.temperature,
                    feelsLike: hourly.feelsLike,
                    weatherDescription: weatherDescription,
                    weatherIcon: weatherIcon,
                    humidity: hourly.humidity,
                    windSpeed: hourly.windSpeed,
                    customTimeString: timeString
                )
                hourlyArray.append(forecast)
                
                let dayType = isToday ? "Сегодня" : "Завтра"
                print("\(dayType) \(timeString): \(hourly.temperature)°C, \(weatherDescription)")
            }
        }
        
        hourlyArray.sort { $0.time < $1.time }
        
        print("Показано записей: \(hourlyArray.count)")
        
        self.cityName = cityName
        self.current = current
        self.forecast = forecastArray
        self.hourlyForecast = hourlyArray
    }
}
