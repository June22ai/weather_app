//
//  LoginViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/04/26.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseAuth

class LoginViewController: UIViewController, FUIAuthDelegate {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // すでにログイン済みならメイン画面へ
        if Auth.auth().currentUser != nil {
            transitionToMain()
            return
        }
        
        // FirebaseUIでログイン画面を表示
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        authUI.providers = [FUIGoogleAuth(authUI: authUI)]

        let authViewController = authUI.authViewController()
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    // ログイン完了時
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print("ログインエラー: \(error.localizedDescription)")
            return
        }
        // ログイン成功 → メイン画面へ遷移
        transitionToMain()
    }

    func transitionToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController")
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true, completion: nil)
    }
}
