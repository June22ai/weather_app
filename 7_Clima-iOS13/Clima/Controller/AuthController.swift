//
//  AuthController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/05/04.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class AuthController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // 新規ユーザー作成ボタン
    @IBAction private func onSignUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email or password is empty.")
            return
        }
        
        // メールとパスワードでユーザー作成
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            print("Successfully created user: \(result?.user.email ?? "")")
                       self.navigateToWeatherView()

        }
    }
    
    // ログインボタン
    @IBAction private func onLoginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email or password is empty.")
            return
        }
        
        // メールとパスワードでサインイン
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            print("Successfully logged in: \(result?.user.email ?? "")")
                       self.navigateToWeatherView()

        }
    }
    // WeatherViewControllerに遷移する処理
    private func navigateToWeatherView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let weatherVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController {
            
            self.present(weatherVC, animated: true, completion: nil)
        } else {
            print("Failed to instantiate WeatherViewController")
        }
    }
    
}
