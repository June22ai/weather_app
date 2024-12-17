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
    // 画面遷移用のメソッド（ボタン押下時に遷移する例）
        @IBAction func GoBack(_ sender: UIButton) {
            
// ナビゲーションコントローラーが存在する場合に戻る
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                print("Error: NavigationController is not available.")
            }
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

