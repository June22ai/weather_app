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
    
    //MARK:- 次の画面へ遷移するためのボタンアクション
    @IBAction func NextPage(_ sender: UIButton) {
                performSegue(withIdentifier: "showFavoreteScreen", sender: nil)
            //}
        // 遷移先のビューコントローラーを NavigationController でラップして遷移
        let favoreteVC = FavoreteViewController()
        let navigationController = UINavigationController(rootViewController: favoreteVC)
        present(navigationController, animated: true, completion: nil)
    }
        
    //    // Segueの準備
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    // 遷移先がFavoreteViewControllerであるか確認
    //        if segue.destination is FavoreteViewController {
    //
    //        }
    //    }
//    // Segueの準備
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // 遷移先が FavoreteViewController であるか確認
//        if segue.identifier == "showFavoreteScreen" {
//            if let navigationController = segue.destination as? UINavigationController {
//                if navigationController.topViewController is FavoreteViewController {
//                    // 必要ならデータを渡す処理
//                }
//            }
//        }
//    }
//MARK:- お気に入り画面へ遷移するためのボタンアクション
    @IBAction func favoriteButtun(_ sender: UIButton) {
        
        // 遷移先の画面を作成
        let favoreteVC = FavoreteViewController()
        
        // UINavigationControllerを作成
        let navigationController = UINavigationController(rootViewController: favoreteVC)
        
    
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .flipHorizontal
        // 右にスライド
        
        // 画面遷移
        present(navigationController, animated: true, completion: nil)
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
