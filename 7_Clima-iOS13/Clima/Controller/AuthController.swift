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
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    
    // 新規ユーザー作成ボタン
    @IBAction private func onSignUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email or password is empty.")
            return
        }
        // メールとパスワードでサインイン
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            print("Successfully created user: \(result?.user.email ?? "")")
            self.showAlertAndNavigate(message: "新規登録しました")
        }
        
    }
    
    // ログインボタン
    @IBAction private func onLoginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "メールアドレスとパスワードを入力してください"
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self.errorLabel.text = "メールアドレスまたはパスワードが違います"
                return
            }
            
            self.errorLabel.text = "" // エラーをクリア
            self.showAlertAndNavigate(message: nil)
        }
    }
    
    
    
    private func showAlertAndNavigate(message: String?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let weatherVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController {
            weatherVC.modalPresentationStyle = .fullScreen
            if let message = message {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.present(weatherVC, animated: true)
                })
                self.present(alert, animated: true)
            } else {
                self.present(weatherVC, animated: true)
            }
        }
    }
    
    
}
