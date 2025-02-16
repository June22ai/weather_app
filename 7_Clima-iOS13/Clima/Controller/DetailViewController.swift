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
    
    // カタカナ都市名と英語都市名のマッピング辞書
    let cityNameDictionary: [String: String] = [
        "東京": "Tokyo",
        "ベルリン": "Berlin",
        "アムステルダム": "Amsterdam",
        "ロンドン": "London",
        "バンコク": "Bangkok",
        "シドニー": "Sydney",
        "メルボルン": "Melbourne",
        "ケープタウン": "Cape Town"
        // 他の都市名もここに追加可能
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WeatherDataManagerのデリゲートを設定
        weatherManager.delegate = self
        
        //ここにカタカナから英語に変換するコードを記述する
        if let cityName = cityName {
            if let englishCityName = cityNameDictionary[cityName] {
                // 辞書にあれば英語名に変換
                self.cityName = englishCityName
            }
            cityLabel.text = self.cityName
            // 天気情報を取得するためにAPI通信を呼び出す
            if let cityName = self.cityName {
                weatherManager.fetchWeather(cityName) // 天気情報を取得
            }
            
        }
        
    }
    // WeatherManagerDelegateメソッド - 天気情報が更新された場合
    func updateWeather(weatherModel: WeatherModel) {
        DispatchQueue.main.async {
            
            // 小数点以下を切り捨てて整数に変換
            let temperature = Int(weatherModel.temperature)  // temperatureは気温の値
            
            // 整数として表示
            self.temperatureLabel.text = "\(temperature)"
            // conditionName を使って、天気アイコンを表示
            let condition = weatherModel.conditionName
            switch condition {
            case "cloud.bolt":
                self.conditionImageView.image = UIImage(systemName: "cloud.bolt")
            case "cloud.drizzle":
                self.conditionImageView.image = UIImage(systemName: "cloud.drizzle")
            case "cloud.rain":
                self.conditionImageView.image = UIImage(systemName: "cloud.rain")
            case "cloud.snow":
                self.conditionImageView.image = UIImage(systemName: "cloud.snow")
            case "cloud.fog":
                self.conditionImageView.image = UIImage(systemName: "cloud.fog")
            case "sun.max":
                self.conditionImageView.image = UIImage(systemName: "sun.max")
            default:
                self.conditionImageView.image = UIImage(systemName: "cloud")
            }
        }
    }
    
    
    // WeatherManagerDelegateメソッド - エラーが発生した場合
    func failedWithError(error: Error) {
        DispatchQueue.main.async {
            print("Error: \(error.localizedDescription)")  // デバッグ用
            self.temperatureLabel.text = "天気情報の取得に失敗しました"
            self.conditionImageView.image = nil
        }
    }
    
    //WeatherModel に Decodable プロトコルを適用。Decodable に準拠することで、JSONDecoder がデータを自動的にデコードできるようになる
    func fetchWeather(cityName: String) {
    //
        let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY&units=metric&q=\(encodedCityName)"

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
