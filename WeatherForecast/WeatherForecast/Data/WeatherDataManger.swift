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

struct URI {
    static let baseURL = "https://api.openweathermap.org/"
    static let currentPath = "data/2.5/weather?"
    static let fiveDaysPath = "data/2.5/forecast?"
    static let appID = "&appid=af361cc4ac7bf412119174d64ba296ff"
    static let units = "&units=metric"
    static let lang = "&lang=kr"
    var queries = [QueryParam]()
    enum PathType {
        case current
        case fiveDays
    }
    
    struct QueryParam {
        let name: String
        let value: String
    }
    
    func generateQuery() {
        
    }
}

final class WeatherDataManager {
    static let shared = WeatherDataManager()
    private init() {}
    private var isPathCurrent = true

    var latitude: Double?
    var longitude: Double?
    var location: CLLocation {
        if let lat = latitude, let lon = longitude {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return CLLocation()
    }
}
 
extension WeatherDataManager {
    func fetchCurrentWeather() {
        let url = generateURI(isCurrentPath: true, location: location)
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
        let url = generateURI(isCurrentPath: false, location: location)
        self.fetch(urlString: url) { (result: Result<FivedaysWeather, APIError>) in
            switch result {
            case .success(let currentWeather):
                return print(currentWeather)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func generateURI(isCurrentPath: Bool, location: CLLocation) -> String {
        let latString = "lat=\(location.coordinate.latitude)"
        let lonString = "&lon=\(location.coordinate.longitude)"

        isPathCurrent = isCurrentPath

        var uri: String {
            if isPathCurrent {
                return "\(URI.baseURL)\(URI.currentPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
            } else {
                return "\(URI.baseURL)\(URI.fiveDaysPath)\(latString)\(lonString)\(URI.appID)\(URI.units)\(URI.lang)"
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


