//
//  AppDelegate.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth  // FirebaseAuthが必要な場合
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    // アプリ起動時にFirebaseを初期化する
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebaseの設定
        FirebaseApp.configure()
        
        return true
    }
    
    // URLスキームを処理するために必要
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Auth.auth().canHandle(url) {
        //Firebase認証の場合はAuthのメソッドを使用してURLスキームを処理
        return Auth.auth().canHandle(url)
    }
        // その他の処理
           return false
       }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // 新しいシーンが作成される際に呼ばれる
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // ユーザーがシーンセッションを破棄した際に呼ばれる
    }
    
}



