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
        WeatherDataManager.shared.fetchCurrentWeather()
        
//        generateLocationManager()
//        bringCoordinates()
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
}
