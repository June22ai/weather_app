//
//  ViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/01/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        locationManager.delegate = self
        //        weatherManager.delegate = self
        
        //}
        // 背景画像を設定するUIImageViewを作成
        let backgroundImageView = UIImageView()
        
        // Assetsに追加した画像を指定
        backgroundImageView.image = UIImage(named: "background")
        
        // 画像のコンテンツモードを設定
        backgroundImageView.contentMode = .scaleAspectFill
        
        // 背景画像が重なることを避けるために背面に配置
        backgroundImageView.layer.zPosition = -1
        
        // 背景画像をビューに追加
        self.view.addSubview(backgroundImageView)
    }
}
