//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation

class WeatherListViewController: UIViewController {
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocationCoordinate2D!
    override func viewDidLoad() {
        super.viewDidLoad()
        generateLocationManager()
        bringCoordinates()
        converToAddress(with: test())
    }
}

extension WeatherListViewController: CLLocationManagerDelegate {
    func test() -> CLLocation {
        let manager = WeatherDataManager.shared
        guard let latitude = manager.latitude, let longitude = manager.longitude else { return CLLocation() }
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            currentLocation = manager.location?.coordinate
            WeatherDataManager.shared.longitude = currentLocation.longitude
            WeatherDataManager.shared.latitude = currentLocation.latitude
            WeatherDataManager.shared.fetchCurrentWeather()
        case .notDetermined, .restricted:
            manager.requestWhenInUseAuthorization()
        case .denied:
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func generateLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    private func bringCoordinates() {
        
        if CLLocationManager.locationServicesEnabled() {
            let currentCoordinate = locationManager.location?.coordinate
            print("위치 서비스 확인")
            
            locationManager.startUpdatingLocation()
            guard let lat = currentCoordinate?.latitude, let lon = currentCoordinate?.longitude else {
                WeatherDataManager.shared.latitude = WeatherDataManager.shared.initialLat
                WeatherDataManager.shared.longitude = WeatherDataManager.shared.initialLon
                print("위치 서비스 이용 동의 전")
                
                return
            }
            WeatherDataManager.shared.latitude = lat
            WeatherDataManager.shared.longitude = lon
        }
    }
    
    func converToAddress(with coordinate: CLLocation) {
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "ko_kr")
        
        geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale) { placemark, error in
            if error != nil {
                print(error)
                return
            }
            
            guard let placemark = placemark?.first,
                  let addressList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                      return
                  }
            
            let address = addressList.joined(separator: " ")
            guard let newAddress = addressList.first?.components(separatedBy: " ") else { return }
            print(newAddress)
            let currentArea = newAddress[0]
            let currentCity = newAddress[1]
            print(currentArea, currentCity)
        }
    }
}
