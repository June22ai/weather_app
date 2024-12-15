//
//  FavoreteViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2024/12/09.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class FavoreteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func GoBack(_ sender: Any) {
        
        //Storyboardで別のViewControllerに遷移する
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") {
                self.present(nextViewController, animated: true, completion: nil)
            }
//        let next = storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") {
//            self.present(next!, animated: true, completion: nil)
//
//        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
