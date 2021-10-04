//
//  WeatherDataManger.swift
//  WeatherForecast
//
//  Created by 호싱잉, 잼킹 on 2021/09/28.
//

import Foundation
import CoreLocation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyData
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .emptyData:
            return "Empty Data"
        case .decodingError:
            return "Decoding Error"
        case .unknown:
            return "Unknown"
        }
    }
}

enum URI {
    static let host = "https://api.openweathermap.org/"
    static let currentPath = "data/2.5/weather?"
    static let fiveDaysPath = "data/2.5/forecast?"
    static let appID = "&appid=af361cc4ac7bf412119174d64ba296ff"
    static let units = "&units=metric"
    static let lang = "&lang=kr"
}

final class WeatherDataManager {
    static let shared = WeatherDataManager()
    private var isPathCurrent = true
    var initialLat = 126.96693
    var initialLon = 37.61831
    var latitude: Double?
    var longitude: Double?
    
    
    private init() {}
    
    func fetchCurrentWeather() {
        let url = generateURI(path: true, location: location)
        self.fetch(urlString: url) { (result: Result<CurrentWeather, APIError>) in
            switch result {
            case .success(let currentWeather):
                return print(currentWeather)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchFiveDaysWeather() {
        let url = generateURI(path: false, location: location)
        self.fetch(urlString: url) { (result: Result<FivedaysWeather, APIError>) in
            switch result {
            case .success(let currentWeather):
                return print(currentWeather)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    var location: CLLocation {
        if let lat = latitude, let lon = longitude {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return CLLocation(latitude: initialLat, longitude: initialLon)
    }
    
//    private func generateLocation() -> CLLocation {
//        guard let lat = latitude, let lon = longitude else { return CLLocation(latitude: initialLat, longitude: initialLon) }
//        let location = CLLocation(latitude: lat, longitude: lon)
//        return location
//    }
    
//    func generateURI(lat: Double?, lon: Double?, path: Bool) -> String {
//        guard let lat = lat, let lon = lon else { return "" }
//        let latString = "lat=\(lat)"
//        let lonString = "&lon=\(lon)"
//
//        isPathCurrent = path
//
//        var uri: String {
//            if isPathCurrent {
//                return "\(URI.host)\(URI.currentPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
//            } else {
//                return "\(URI.host)\(URI.fiveDaysPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
//            }
//        }
//        return uri
//    }
    
    func generateURI(path: Bool, location: CLLocation) -> String {
        let latString = "lat=\(location.coordinate.latitude)"
        let lonString = "&lon=\(location.coordinate.longitude)"

        isPathCurrent = path

        var uri: String {
            if isPathCurrent {
                return "\(URI.host)\(URI.currentPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
            } else {
                return "\(URI.host)\(URI.fiveDaysPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
            }
        }
        return uri
    }
}

extension WeatherDataManager: JSONDecodable {
    private func fetch<ParsingType: Decodable>(urlString: String, completion: @escaping (Result<ParsingType, APIError>) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.invalidURL))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.emptyData))
                return
            }
         
            do {
                let data = try self.decodeJSON(ParsingType.self, from: data)
                completion(.success(data))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}


