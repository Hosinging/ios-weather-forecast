//
//  WeatherForecastTests - WeatherForecastTests.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import XCTest
@testable import WeatherForecast

class WeatherForecastTests: XCTestCase {
    
    func testCurrentWeatherDecode() {
        let jsonDecorder: JSONDecoder = JSONDecoder()
        guard let currentWeatherDataAsset: NSDataAsset = NSDataAsset(name: "CurrentWeather") else {
            return
        }
        
        do {
            let result = try jsonDecorder.decode(CurrentWeather.self, from: currentWeatherDataAsset.data)
            let lat = result.coordinate.lat
            let lon = result.coordinate.lon
            let cityName = result.cityName
            let weatherIcon = result.icon[0].name
            let weatherIconDescription = result.icon[0].description
            let averageTemp = result.temperature.average
            let minimunTemp = result.temperature.minimun
            let maximunTemp = result.temperature.maximum
            let windSpeed = result.wind.speed
            let sunriseTime = result.sys.sunrise
        
            let date = Date(timeIntervalSince1970: sunriseTime)
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "Kr")
            formatter.dateStyle = .medium
            let localDate = formatter.string(from: date)
            
            XCTAssertEqual(37.39, lat, "lat Decode Error")
            XCTAssertEqual(-122.08, lon, "lon Decode Error")
            XCTAssertEqual("Mountain View", cityName, "cityName Decode Error")
            XCTAssertEqual("01d", weatherIcon, "weatherIcon Decode Error")
            XCTAssertEqual("clear sky", weatherIconDescription, "weatherIconDescription Decode Error")
            XCTAssertEqual(282.55, averageTemp, "temperature Decode Error")
            XCTAssertEqual(280.37, minimunTemp, "temperature Decode Error")
            XCTAssertEqual(284.26, maximunTemp, "temperature Decode Error")
            XCTAssertEqual(1.5, windSpeed, "temperature Decode Error")
            XCTAssertEqual(284.26, maximunTemp, "temperature Decode Error")
            XCTAssertEqual("Jun 12, 2019", localDate, "temperature Decode Error")
        } catch {
            print(error)
        }
    }
    
    func testForecastListDecode() {
        let jsonDecorder: JSONDecoder = JSONDecoder()
        guard let currentWeatherDataAsset: NSDataAsset = NSDataAsset(name: "5DayWeatherForecast") else {
            return
        }
        
        do {
            let result = try jsonDecorder.decode(ForecastList.self, from: currentWeatherDataAsset.data)
            let count = result.count
            let dateTime = result.list[0].dateTime
            let weatherIcon = result.list[0].weatehrIcon[0].name
            let averageTemp = result.list[0].temperature.average
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateTimeString = formatter.string(from: dateTime)
            
            XCTAssertEqual(40, count, "forecastList count Decode Error")
            XCTAssertEqual("04d", weatherIcon, "weatherIcon Decode Error")
            XCTAssertEqual(273.81, averageTemp, "temperature Decode Error")
            XCTAssertEqual("2021-01-18 06:00:00", dateTimeString, "dateTime Decode Error")
        } catch {
            print(error)
        }
    }
    
}
