//
//  FavoreteViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2024/12/09.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class FavoreteViewController: UIViewController {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//segue.destinationがFavoreteViewController型かどうかをチェック
        if segue.destination is FavoreteViewController {
            // 型チェックだけ行って特に処理はしない
            print("遷移先は FavoreteViewController です")
            
        }
    }
    @IBAction func GoBack(_ sender: UIButton) {
    //今回はナビゲーションコントローラーは使用していないので↓が呼ばれる事はない
        if let navigationController = self.navigationController {
            //ナビゲーションスタックの一番上の画面（FavoriteViewController）をポップして戻る
            navigationController.popViewController(animated: true)
        } else {
            // モーダル遷移している場合はdismissを使う
            dismiss(animated: true, completion: nil)
        }
            
        }
    }

