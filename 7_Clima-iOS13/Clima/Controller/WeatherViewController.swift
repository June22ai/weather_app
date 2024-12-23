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
// MARK:- DadJokeメソッド追加
extension WeatherViewController {
        
    @IBAction func fetchDadJoke() {
        //APIのURL
        let urlString = "https://icanhazdadjoke.com/api"
        //URLを作成
        guard let url = URL(string: urlString) else { return }
        //URLリクエストの設定
        var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        //JSON形式でのレスポンスを指定
            //レスポンスのデータはJSON形式
        //APIにGETリクエストを送信
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //エラーチェック
            if let error = error {
                print("Error fetching joke: \(error)")
                    return
                }
                
            //データが存在する場合
            if let data = data {
                do {
                //JSONデータをパース
                //JSONは辞書型[String: Any]として解析される
                //その中から"joke"というキーに対応する値（文字列）を取り出す
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let joke = json["joke"] as? String {
                        //ジョークを表示（UIの更新をメインスレッドで行う）
                        DispatchQueue.main.async {
                            self.jokeLabel.text = joke
                            }
                        }
                } catch {
                    print("Error parsing JSON: \(error)")
                    }
                }
            }
            
            // タスク開始
            task.resume()
        }
        
    }
