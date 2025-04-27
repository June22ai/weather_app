//
//  UserConnectionViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/04/26.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserConnectionViewController: UIViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var currentUserIdLabel: UILabel!
    @IBOutlet weak var currentNameTextField: UITextField!
    @IBOutlet weak var currentNameLabel: UILabel!
    @IBOutlet weak var currentAgeTextField: UITextField!
    @IBOutlet weak var currentAgeLabel: UILabel!
    @IBOutlet weak var deleteUserButton: UIButton!
    
    var ref: DatabaseReference!
    
    var currentUserId: String? {
        didSet {
            updateUI()
        }
    }
    
    var currentUserName: String? {
        didSet {
            updateUI()
        }
    }
    
    var currentUserAge: Int? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // 初期状態では接続されていない
        connectionStatusLabel.text = "未接続"
        currentUserIdLabel.text = "---"
        currentNameLabel.text = "---"
        currentAgeLabel.text = "---"
    }
    
    // 接続ボタンを押した時の処理
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        guard let userId = userIdTextField.text, !userId.isEmpty else {
            print("ユーザーIDを入力してください。")
            return
        }
        
        // Firebase Realtime Database から接続
        ref.child("User").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let userDict = snapshot.value as? [String: Any] {
                self.currentUserId = userId
                self.currentUserName = userDict["name"] as? String
                self.currentUserAge = userDict["age"] as? Int
                self.connectionStatusLabel.text = "接続済み"
            } else {
                self.connectionStatusLabel.text = "ユーザーIDが存在しません"
            }
        }
    }
    
    // 名前を変更した時の処理
    @IBAction func updateNameButtonTapped(_ sender: UIButton) {
        guard let newName = currentNameTextField.text, !newName.isEmpty else {
            print("名前を入力してください。")
            return
        }
        
        // Realtime Database の名前を更新
        if let userId = currentUserId {
            ref.child("User").child(userId).updateChildValues(["name": newName]) { error, _ in
                if let error = error {
                    print("名前の更新に失敗しました: \(error.localizedDescription)")
                } else {
                    self.currentNameLabel.text = newName
                    print("名前が更新されました。")
                }
            }
        }
    }
    
    // 年齢を変更した時の処理
    @IBAction func updateAgeButtonTapped(_ sender: UIButton) {
        guard let newAgeText = currentAgeTextField.text, let newAge = Int(newAgeText) else {
            print("年齢を正しく入力してください。")
            return
        }
        
        // Realtime Database の年齢を更新
        if let userId = currentUserId {
            ref.child("User").child(userId).updateChildValues(["age": newAge]) { error, _ in
                if let error = error {
                    print("年齢の更新に失敗しました: \(error.localizedDescription)")
                } else {
                    self.currentAgeLabel.text = "\(newAge)"
                    print("年齢が更新されました。")
                }
            }
        }
    }
    
    // ユーザー削除処理
    @IBAction func deleteUserButtonTapped(_ sender: UIButton) {
        if let userId = currentUserId {
            ref.child("User").child(userId).removeValue { error, _ in
                if let error = error {
                    print("ユーザーの削除に失敗しました: \(error.localizedDescription)")
                } else {
                    self.currentUserId = nil
                    self.currentUserName = nil
                    self.currentUserAge = nil
                    self.connectionStatusLabel.text = "########## 未接続 ##########"
                    self.currentUserIdLabel.text = "---"
                    self.currentNameLabel.text = "---"
                    self.currentAgeLabel.text = "---"
                    print("ユーザーが削除されました。")
                }
            }
        }
    }
    
    // UI 更新処理
    func updateUI() {
        guard let userId = currentUserId else { return }
        currentUserIdLabel.text = userId
        currentNameLabel.text = currentUserName ?? "---"
        currentAgeLabel.text = currentUserAge != nil ? "\(currentUserAge!)" : "---"
    }
}
