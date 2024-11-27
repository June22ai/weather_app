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
            searchField.endEditing(true)    //dismiss keyboard
            print(searchField.text!)
            
            searchWeather()
        }
    
        func searchWeather(){
            if let cityName = searchField.text{
                // 入力された都市名に基づいて背景画像を変更
                changeBackgroundImage(for: cityName)
                weatherManager.fetchWeather(cityName)
            }
        }
        
        // when keyboard return clicked
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            searchField.endEditing(true)    //dismiss keyboard
            print(searchField.text!)
            
            searchWeather()
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
    
    func updateWeather(weatherModel: WeatherModel){
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            cityLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            // 天気情報に応じて背景画像を設定
            self.backgroundImageView.image = UIImage(systemName: "tokyo_background")
            
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
        // 入力された都市名が"tokyo"の場合のみ背景画像を変更
        guard cityName.lowercased() == "tokyo" else {
            // "tokyo"以外の場合、処理を何もせずに戻る
            return
        }
        
        // "tokyo"の場合のみ背景画像を変更
        self.backgroundImageView.image = UIImage(named: "tokyo_background")
    }
}

// MARK:- 背景画像変更メソッド追加
//extension WeatherViewController {
//
//    func changeBackgroundImage(for cityName: String) {
//        // 入力された都市名に基づいて背景画像を変更
//        if cityName.lowercased() == "tokyo" {
//            self.backgroundImageView.image = UIImage(named: "tokyo_background")
//        } else {
//            self.backgroundImageView.image = UIImage(named: "night_background")
//            // 他の都市名が入力された時の背景
//        }
//    }
//}
