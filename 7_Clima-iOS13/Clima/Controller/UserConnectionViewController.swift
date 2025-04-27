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
    
    @IBOutlet weak var targetIdText: UITextField!// 接続先ユーザーIDの入力ボックス
    @IBOutlet weak var connectButton: UIButton!// 接続ボタン
    @IBOutlet weak var stateLabel: UILabel!// 接続状態ラベル
    @IBOutlet weak var userIdLabel: UILabel!// 接続されたユーザーIDラベル
    @IBOutlet weak var nameText: UITextField!// DBへリアルタイムに更新する名前の入力ボックス
    @IBOutlet weak var nameLabel: UILabel!// DBからリアルタイムに参照された名前ラベル
    @IBOutlet weak var ageText: UITextField!// DBへリアルタイムに更新する年齢の入力ボックス
    @IBOutlet weak var ageLabel: UILabel!// DBからリアルタイムに参照された年齢ラベル
    @IBOutlet weak var deleteButton: UIButton!// ユーザーの削除ボタン
    
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
        stateLabel.text = "未接続"
        userIdLabel.text = "---"
        nameLabel.text = "---"
        ageLabel.text = "---"
    }
    
    // 接続ボタンを押した時の処理
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        guard let userId = targetIdText.text, !userId.isEmpty else {
            print("ユーザーIDを入力してください。")
            return
        }
        
        // Firebase Realtime Database から接続
        ref.child("User").child(userId).observeSingleEvent(of: .value) { snapshot, error in

            if let error = error {
                print("データ取得中にエラーが発生しました: \(error)")
                return
            }

            // snapshotからデータを取り出す
            if let value = snapshot.value as? [String: Any] {
                // ここでvalueから名前や年齢を取り出してラベルに表示します
                let userName = value["name"] as? String ?? "未設定"
                let userAge = value["age"] as? Int ?? 0
                
                // ラベルにセット
                self.nameLabel.text = userName
                self.ageLabel.text = "\(userAge)"
            }
        }

   }
    
    // 名前を変更した時の処理
    @IBAction func updateNameButtonTapped(_ sender: UIButton) {
        guard let newName = nameText.text, !newName.isEmpty else {
            print("名前を入力してください。")
            return
        }
        
        // Realtime Database の名前を更新
        if let userId = currentUserId {
            ref.child("User").child(userId).updateChildValues(["name": newName]) { error, _ in
                if let error = error {
                    print("名前の更新に失敗しました: \(error.localizedDescription)")
                } else {
                    self.nameLabel.text = newName
                    print("名前が更新されました。")
                }
            }
        }
    }
    
    // 年齢を変更した時の処理
    @IBAction func updateAgeButtonTapped(_ sender: UIButton) {
        guard let newAgeText = ageText.text, let newAge = Int(newAgeText) else {
            print("年齢を正しく入力してください。")
            return
        }
        
        // Realtime Database の年齢を更新
        if let userId = currentUserId {
            ref.child("User").child(userId).updateChildValues(["age": newAge]) { error, _ in
                if let error = error {
                    print("年齢の更新に失敗しました: \(error.localizedDescription)")
                } else {
                    self.ageLabel.text = "\(newAge)"
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
                    self.stateLabel.text = "########## 未接続 ##########"
                    self.userIdLabel.text = "---"
                    self.nameLabel.text = "---"
                    self.ageLabel.text = "---"
                    print("ユーザーが削除されました。")
                }
            }
        }
    }
    
    // UI 更新処理
    func updateUI() {
        guard let userId = currentUserId else { return }
        userIdLabel.text = userId
        nameLabel.text = currentUserName ?? "---"
        ageLabel.text = currentUserAge != nil ? "\(currentUserAge!)" : "---"
    }
}
