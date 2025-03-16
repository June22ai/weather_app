//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftUI
import RswiftResources

class WeatherViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate  {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var jokeLabel: UILabel!
    
    
    //MARK: Properties
    var apiService = APIService() // APIService のインスタンスを作成
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        //weatherManager.delegate = self
        searchField.delegate = self
        
    }
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
    
    //MARK:- お気に入り画面へ遷移するためのボタンアクション
    @IBAction func favoriteButtun(_ sender: UIButton) {
        
    }
    
        //MARK:- 次の画面へ遷移するためのボタンアクション
    @IBAction func NextPage(_ sender: UIButton) {
            performSegue(withIdentifier: "showFavoreteScreen", sender: nil)
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showFavoreteScreen"{
            }
        }
    
    //MARK:- TextField extension
    @IBAction func searchBtnClicked(_ sender: UIButton) {
        
        searchField.endEditing(true)    //dismiss keyboard
        
        searchWeather()
    }
    
    
    // MARK: - Search Weather Method
    func searchWeather() {
        guard let cityName = searchField.text, !cityName.isEmpty else {
            print("City name is empty or nil.")
            return
        }
        fetchWeatherByCityName(cityName)
    }
    
    // MARK: - Fetch Weather by City Name
    func fetchWeatherByCityName(_ cityName: String) {
        let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName
        //let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY&units=metric&q=\(encodedCityName)"
        let urlString = "\(R.string.localizable.weatherAPIBaseURL)\(encodedCityName)&appid=\(R.string.localizable.apiKey)&units=metric"
        
        apiService.fetchData(urlString: urlString) { [weak self] (result: Result<WeatherModel, APIError>) in
            switch result {
            case .success(let weatherModel):
                DispatchQueue.main.async {
                    self?.updateWeather(weatherModel)
                }
            case .failure(let error):
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    // MARK: - Fetch Weather by Coordinates
    func fetchWeatherByCoordinates(lat: Double, lon: Double) {
        
        let urlString = "\(R.string.localizable.weatherAPIBaseURL)lat=\(lat)&lon=\(lon)&appid=\(R.string.localizable.apiKey)&units=metric"
        
        
        apiService.fetchData(urlString: urlString) { [weak self] (result: Result<WeatherModel, APIError>) in
            switch result {
            case .success(let weatherModel):
                DispatchQueue.main.async {
                    self?.updateWeather(weatherModel)
                }
            case .failure(let error):
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    // MARK: - Update Weather UI
    func updateWeather(_ weatherModel: WeatherModel) {
        temperatureLabel.text = weatherModel.temperatureString
        cityLabel.text = weatherModel.cityName
        conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
        backgroundImageView.image = UIImage(systemName: "dark_background")
        changeBackgroundImage(for: weatherModel.cityName)
    }
    
    // MARK: - Change Background Image背景画像変更メソッド追加
    func changeBackgroundImage(for cityName: String) {
        //入力された都市名に基づいて背景画像を変更
        if cityName.lowercased() == "tokyo" {
            backgroundImageView.image = UIImage(named: R.image.tokyo_background.name)
        } else {
            backgroundImageView.image = UIImage(named: R.image.background.name)
        }
        
    }
    
    // MARK:- DadJokeメソッド追加
    @IBAction func fetchDadJoke() {
    // ランダムなジョークを取得するためのURL
    //urlString のようにコード内で固定的に使用する文字列（APIのURLなど）は、Localizable.stringsに記載する必要はない
        
        guard let url = URL(string: "https://icanhazdadjoke.com/") else {
            return
        }
        
        // ヘッダーを設定してリクエストを作成
        let headers = ["Accept": "application/json"]
        
        // APIServiceを使ってリクエストを送信
        APIService.request(url: url, headers: headers) { (result: Result<JokeResponse, Error>) in
            switch result {
            case .success(let jokeResponse):
                DispatchQueue.main.async {
                    self.displayJoke(jokeResponse.joke)
                }
            case .failure(let error):
                print("Error fetching joke: \(error.localizedDescription)")
                
            }
        }
    }
    
    // ジョークをUIに表示
    func displayJoke(_ joke: String) {
        jokeLabel.text = joke
    }
}


// MARK: - WeatherManagerDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        searchWeather()
        return true
    }
}
// MARK: - test
struct SampleView: View {
    var body: some View {
        VStack {
            Text(R.string.localizable.greeting())  // 文字列
                .font(.largeTitle)
                .foregroundColor(Color(R.color.primary))  // 色
            
            Image(R.image.icon)  // 画像
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
    }
}

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
    }
}
