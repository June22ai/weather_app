//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var jokeLabel: UILabel!
    
    
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        weatherManager.delegate = self
        searchField.delegate = self
        
    }
    
    
}

//MARK:- TextField extension
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchBtnClicked(_ sender: UIButton) {
        self.searchField.endEditing(true)    //dismiss keyboard
        print(self.searchField.text!)
        
        self.searchWeather() //searchWeather()メソッドを呼び出す
    }
    
    
    func searchWeather() {
        guard let cityName = searchField.text, !cityName.isEmpty else {
            //cityNameがnilまたは空文字の場合、ここで処理を中断
            print("City name is empty or nil.")
            return
        }
        
        //コンソールにログ出力 (都市名と共に
        print("action:search, city:\(cityName)")
        //都市名を渡して天気データを取得
        self.weatherManager.fetchWeather(cityName)
    }
    
    
    // when keyboard return clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchField.endEditing(true)//dismiss keyboard
        print(self.searchField.text!)
        
        self.searchWeather()// searchWeather() メソッドを呼び出す
        return true
    }
    
    // when textfield deselected
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // by using "textField" (not "searchField") this applied to any textField in this Controller(cuz of delegate = self)
        if textField.text != "" {
            return true
        }else{
            textField.placeholder = "Type something here"
            return false            // check if city name is valid
        }
    }
    
    // when textfield stop editing (keyboard dismissed)
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        searchField.text = ""   // clear textField
    }
    
}
//MARK:- View update extension
extension WeatherViewController: WeatherManagerDelegate {
    //検索してきた結果を取得、更新
    //ここで背景画像を変更する処理
    func updateWeather(weatherModel: WeatherModel){
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            cityLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            //入力された都市名に基づいて背景画像を変更
            changeBackgroundImage(for:weatherModel.cityName)
            
        }
    }
    
    func failedWithError(error: Error){
        print(error)
    }
}

// MARK:- CLLocation
extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        // Get permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(lat, lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK:- 背景画像変更メソッド追加
extension WeatherViewController {
    
    func changeBackgroundImage(for cityName: String) {
        //入力された都市名に基づいて背景画像を変更
        if cityName.lowercased() == "tokyo" {
            self.backgroundImageView.image = UIImage(named: "tokyo_background")
        } else {
            self.backgroundImageView.image = UIImage(named: "background")
            // 他の都市名が入力された時の背景
        }
    }
}
// MARK:- DadJokeメソッド追加
extension WeatherViewController {
    
    @IBAction func fetchDadJoke() {
        
        // ランダムなジョークを取得するためのURL
        guard let url = URL(string: "https://icanhazdadjoke.com/") else {
            print("Invalid URL")
            return
        }
        
        // リクエストの作成
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")  // JSON形式でレスポンスを受け取る
        request.httpMethod = "GET"  // GETリクエスト
        
        // APIリクエストを実行
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            // エラーチェック
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // HTTPレスポンスコードが200（成功）か確認
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                // データが存在する場合はJSONに変換
                if let data = data {
                    do {
                        // JSONデータを辞書型に変換
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        // 取得したジョークの内容を表示
                        if let jsonDict = jsonResponse as? [String: Any],
                           let joke = jsonDict["joke"] as? String {
                            // UI更新はメインスレッドで行う
                            DispatchQueue.main.async {
                                // ジョークを画面に表示する（例: ラベルにセット）
                                print("Random Joke: \(joke)") // コンソールに表示
                                self?.displayJoke(joke) // 表示するためのメソッド呼び出し
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Failed to fetch joke: \(String(describing: response))")
            }
        }
        
        // タスクを実行
        task.resume()
    }
    // ジョークを表示するためのメソッド
    func displayJoke(_ joke: String) {
        // ここでUILabelにジョークを表示
        jokeLabel.text = joke
    }
    
}
