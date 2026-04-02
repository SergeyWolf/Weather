//
//  Date+Weather.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

extension Date {
    func dayOfWeek(locale: Locale = Locale(identifier: "ru_RU")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).capitalized
    }
}
