//
//  ViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/01/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

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
        
    }


    

}
