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
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseAuth
import FirebaseDatabase
import UserNotifications


class WeatherViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate,FUIAuthDelegate  {
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var jokeLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var dadJokeButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton! // 追加: ログアウト用のボタン
    @IBOutlet weak var targetIdText: UIButton!
    
    
    
    
    //MARK: Properties
    var apiService = APIService() // APIService のインスタンスを作成
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    var user: DatabaseReference!    // 参照先DB（Userノード）※UserIdの親ノード
    var userId: DatabaseReference!  // 参照先DB（指定したUserIdノード）
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.setTitle(R.string.localizable.next_screen(), for: .normal)
        favoriteButton.setTitle(R.string.localizable.favorite(), for: .normal)
        dadJokeButton.setTitle(R.string.localizable.dad_joke(), for: .normal)
        
        // その他の初期化
        locationManager.delegate = self
        searchField.delegate = self
        
        if Auth.auth().currentUser != nil {
            logoutButton.isHidden = false
        }
        
        self.user = Database.database().reference().child("user")
        // 通知の許可リクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知の許可がされました")
            } else {
                print("❌ 通知が拒否されました")
            }
            
        }

        // Firebaseの参照先を設定
        self.user = Database.database().reference().child("user")
        
        locationManager.delegate = self
        searchField.delegate = self
        
        // ボタンにローカライズされたタイトルを設定
        nextButton.setTitle(R.string.localizable.next_screen(), for: .normal)
        favoriteButton.setTitle(R.string.localizable.favorite(), for: .normal)
        dadJokeButton.setTitle(R.string.localizable.dad_joke(), for: .normal)
        // ログイン状態に応じてUIを更新
        if let user = Auth.auth().currentUser {
            // ユーザーがログインしている場合
            print("Logged in as \(user.displayName ?? "No Name")")
            // ログイン後のUI更新（例: ログアウトボタンの表示）
            logoutButton.isHidden = false
        } else {
            // ユーザーがログインしていない場合
            print("No user logged in.")
            // ログインボタンの表示（必要なら）
        }
        
        // 現在のユーザー情報を表示
        if let user = Auth.auth().currentUser {
            print("uid:", user.uid)
            print("displayName:", user.displayName ?? "No Display Name")
            print("photoURL:", user.photoURL?.absoluteString ?? "No Photo URL")
        }
    }
    
    
    // ログアウトボタンAuthControllerへ戻る
    @IBAction private func onLogoutButton(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authVC = storyboard.instantiateViewController(withIdentifier: "AuthController") as? AuthController {
                authVC.modalPresentationStyle = .fullScreen
                self.present(authVC, animated: true)
            }
            
        } catch let error {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoriteVC = storyboard.instantiateViewController(withIdentifier: "FavoreteViewController") as? FavoreteViewController {
            // ナビゲーションコントローラに包む
            let navController = UINavigationController(rootViewController: favoriteVC)
            navController.modalPresentationStyle = .fullScreen  // 必要に応じて
            self.present(navController, animated: true, completion: nil)
        }
        
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
       
        let urlString = "\(R.string.localizable.weatherAPIBaseURL)\(encodedCityName)&appid=\(R.string.localizable.apiKey)&units=metric"
        
        // APIService.request メソッドを使用してデータを取得
        APIService.request(urlString: urlString) { [weak self] (result: Result<WeatherModel, APIError>) in
            
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
        
        // APIService.request メソッドを使用してデータを取得
        APIService.request(urlString: urlString) { [weak self] (result: Result<WeatherModel, APIError>) in
            
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
        APIService.request(urlString: url.absoluteString, headers: headers) { (result: Result<JokeResponse, APIError>) in
            
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
