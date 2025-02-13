//
//  DetailViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/02/01.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController, WeatherManagerDelegate {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    // 都市名を受け取るプロパティ
    var cityName: String?
    var weatherManager = WeatherDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WeatherDataManagerのデリゲートを設定
        weatherManager.delegate = self
        
        // 都市名が設定されている場合、その都市の天気を取得
        if let cityName = cityName {
            cityLabel.text = cityName
            weatherManager.fetchWeather(cityName) // 天気情報を取得
        }
        
    }
    // WeatherManagerDelegateメソッド - 天気情報が更新された場合
    func updateWeather(weatherModel: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = "\(weatherModel.temperature)°C"
            
            // 天気情報に応じた画像を表示
            switch weatherModel.conditionId {
            case 200..<300:
                self.conditionImageView.image = UIImage(named: "storm")
            case 300..<400:
                self.conditionImageView.image = UIImage(named: "rain")
            case 500..<600:
                self.conditionImageView.image = UIImage(named: "rain")
            case 600..<700:
                self.conditionImageView.image = UIImage(named: "snow")
            case 700..<800:
                self.conditionImageView.image = UIImage(named: "mist")
            case 800:
                self.conditionImageView.image = UIImage(named: "sunny")
            case 801..<900:
                self.conditionImageView.image = UIImage(named: "cloudy")
            default:
                self.conditionImageView.image = UIImage(named: "default")
            }
        }
    }
    // WeatherManagerDelegateメソッド - エラーが発生した場合
    func failedWithError(error: Error) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = "天気情報の取得に失敗しました"
            self.conditionImageView.image = nil
        }
    }
    //}
 //WeatherModel に Decodable プロトコルを適用。Decodable に準拠することで、JSONDecoder がデータを自動的にデコードできるようになる
    func fetchWeather(cityName: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY&units=metric&q=\(cityName)"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.failedWithError(error: error)
                    }
                    return
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(WeatherModel.self, from: data)
                        DispatchQueue.main.async {
                            self.updateWeather(weatherModel: weatherData)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.failedWithError(error: error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    
}
