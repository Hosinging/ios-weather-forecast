//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation

class WeatherListViewController: UIViewController {
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateLocationManager()
        bringCoordinates()
        WeatherDataManager.shared.fetchCurrentWeather()
        converToAddress(with: CLLocation(latitude: WeatherDataManager.shared.latitude!, longitude: WeatherDataManager.shared.longitude!))
    }
}

extension WeatherListViewController: CLLocationManagerDelegate {
    private func generateLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func bringCoordinates() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        let coordinate = locationManager.location?.coordinate
        WeatherDataManager.shared.latitude = coordinate?.latitude
        WeatherDataManager.shared.longitude = coordinate?.longitude
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
