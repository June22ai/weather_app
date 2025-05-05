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

    
    // MARK: 新規ユーザー作成ボタン (サインアップ)
    @IBAction private func onSignUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email or password is empty.")
            return
        }

        // メールとパスワードでユーザー作成
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            
            // 成功した場合の処理
            if let user = user {
                print("Successfully created user: \(user.user.email ?? "")")
            }
        }
    }

    // MARK: ログインボタン
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
            
            // 成功した場合の処理
            if let user = result?.user {
                print("Successfully logged in: \(user.email ?? "")")
            }
        }
    }
}
