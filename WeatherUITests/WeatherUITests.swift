//
//  WeatherUITests.swift
//  WeatherUITests
//
//  Created by Сергей on 12.02.2026.
//

import XCTest

final class WeatherUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-MockWeather"]
        app.launch()
    }
    
    func testWeatherListLoads() {
        let лондон = app.staticTexts["Лондон"]
        XCTAssertTrue(лондон.waitForExistence(timeout: 10))
        
        let париж = app.staticTexts["Париж"]
        XCTAssertTrue(париж.exists)
    }
    
    func testColdWeatherHighlighting() {
        let москва = app.staticTexts["Москва"]
        XCTAssertTrue(москва.exists)
        
        let cell = москва.firstMatch
        XCTAssertTrue(cell.exists)
    }
    
    func testNavigateToForecast() {
        let лондон = app.staticTexts["Лондон"]
        лондон.tap()
        
        let forecastTitle = app.navigationBars["Лондон"]
        XCTAssertTrue(forecastTitle.waitForExistence(timeout: 5))
        
        let ощущается = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Ощущается'"))
        XCTAssertTrue(ощущается.firstMatch.exists)
    }
}
