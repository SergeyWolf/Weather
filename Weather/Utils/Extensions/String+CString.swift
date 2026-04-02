//
//  String+CString.swift
//  Weather
//
//  Created by Сергей on 12.02.2026.
//

import Foundation

extension String {
    init(cString fixedArray: UnsafePointer<CChar>, maxLength: Int) {
        let length = strnlen(fixedArray, maxLength)
        self = String(bytesNoCopy: UnsafeMutablePointer(mutating: fixedArray),
                     length: length,
                     encoding: .utf8,
                     freeWhenDone: false) ?? ""
    }
}

extension UnsafePointer where Pointee == CChar {
    func safeString(maxLength: Int = 256) -> String {
        let length = strnlen(self, maxLength)
        return String(bytesNoCopy: UnsafeMutablePointer(mutating: self),
                     length: length,
                     encoding: .utf8,
                     freeWhenDone: false) ?? ""
    }
}
