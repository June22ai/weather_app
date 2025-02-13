//
//  WeatherModel.swift
//  Clima
//
//  Created by Daegeon Choi on 2020/04/28.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel: Decodable {
    let cityName: String
    let conditionId: Int
    let temperature: Double
    
    var temperatureString: String{
        return String.init(format: "%.1f", temperature)
    }
    
    // computed property
    var conditionName: String {
        // docs https://openweathermap.org/weather-conditions
        switch conditionId/100 {
        case 2:
            return "cloud.bolt"
        case 3:
            return "cloud.drizzle"
        case 5:
            return "cloud.rain"
        case 6:
            return "cloud.snow"
        case 7:
            return "cloud.fog"
        case 8:
            if conditionId == 800 {
                return "sun.max"
            } else {
                return "cloud.bolt"
            }
        default:
            return "cloud"
        }
    }
  
    // JSONレスポンスに基づいたイニシャライザ（初期化メソッド）
        enum CodingKeys: String, CodingKey {
            case cityName = "name"
            case temperature = "main.temp"
            case conditionId = "weather.0.id"
        }
    }
    
    
    
//}
