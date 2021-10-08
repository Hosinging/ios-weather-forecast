//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation

class WeatherListViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateLocationManager()
//        bringCoordinates()
        convertToAddress()
    }
}

extension WeatherListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            currentLocation = manager.location?.coordinate
            WeatherDataManager.shared.longitude = currentLocation?.longitude
            WeatherDataManager.shared.latitude = currentLocation?.latitude
            WeatherDataManager.shared.fetchCurrentWeather()
        case .notDetermined, .restricted:
            manager.requestWhenInUseAuthorization()
        case .denied:
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
}

extension WeatherListViewController {
    private func generateLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
//    private func generateCurrentCoordinate() -> CLLocation {
//        let manager = WeatherDataManager.shared
//        guard let latitude = manager.latitude, let longitude = manager.longitude else { return CLLocation() }
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        return location
//    }
    
//    private func bringCoordinates() {
//        if CLLocationManager.locationServicesEnabled() {
//            let currentCoordinate = locationManager?.location?.coordinate
//
//            locationManager?.startUpdatingLocation()
//            guard let lat = currentCoordinate?.latitude, let lon = currentCoordinate?.longitude else {
//                return
//            }
//            WeatherDataManager.shared.latitude = lat
//            WeatherDataManager.shared.longitude = lon
//        }
//    }
    
//    private func converToAddress(with coordinate: CLLocation) {
//        let geoCoder = CLGeocoder()
//        let locale = Locale(identifier: "ko_kr")
//
//        geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale) { placemark, error in
//            if error != nil {
//                print(error)
//                return
//            }
//            if let administrativeArea = placemark?.first?.administrativeArea {
//                print(administrativeArea)
//            }
//            if let locality = placemark?.first?.locality {
//                print(locality)
//            }
//        }
//    }
    private func convertToAddress() {
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "ko_kr")
        guard let latitude = WeatherDataManager.shared.latitude, let longitude = WeatherDataManager.shared.longitude else { return }
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale) { placemark, error in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            if let administrativeArea = placemark?.first?.administrativeArea {
                print(administrativeArea)
            }
            if let locality = placemark?.first?.locality {
                print(locality)
            }
        }
    }
    
}
