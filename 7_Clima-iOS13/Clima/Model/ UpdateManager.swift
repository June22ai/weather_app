//
// UpdateManager.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/05/17.
//  Copyright © 2025 App Brewery. All rights reserved.
//
//必要なフレームワークをインポート
import Foundation
import Combine
import Firebase
import FirebaseRemoteConfig
import UIKit
//バージョンのチェックと必要ならばアップデートのアラートを表示するためのクラスを定義
class UpdateCheckManager {
    // Firebase Remote Configのインスタンスをプライベートプロパティとして保持
    private let remoteConfig = RemoteConfig.remoteConfig()
    //updateCheckerのシングルトンインスタンスを作成
    static let shared = UpdateCheckManager()
    //UIApplicationがアクティブになった時に呼ばれる関数を設定
    public func observeApplicationDidBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    //UIApplicationがアクティブになった時にRemote Configを取得し、バージョンのチェック
    @objc private func applicationDidBecomeActive() {
        fetchRemoteConfigAndCheckVersion()
    }
    //Remote Configを取得し、バージョンのチェックを行う関数
    private func fetchRemoteConfigAndCheckVersion() {
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
            guard error == nil else {
                print("error in fetching. value: \(String(describing: error))")
                return
            }
            self.remoteConfig.fetchAndActivate { _, _ in
                if self.checkVersion() {
                    self.showUpdateAlertIfNeeded()
                }
            }
        }
    }
   //Firebaseから取得したバージョンとローカルのアプリのバージョンを比較し、一致しなければtrueを返す
    private func checkVersion() -> Bool {
        let currentVersion = remoteConfig.configValue(forKey: "current_version").stringValue ?? ""
        let localVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return currentVersion != localVersionString
    }
    //バージョンが一致しない場合にアップデートを促すアラートを表示
    private func showUpdateAlertIfNeeded() {
        guard let rootViewController = getTopViewController() else { return }
        
        let alertController = UIAlertController(title: "アップデートが必要です", message: "新しいバージョンがApp Storeにあります。アップデートしてください。", preferredStyle: .alert)

        let updateAction = UIAlertAction(title: "アップデート", style: .default) { _ in
            guard let url = URL(string:
                  "https://weather-app-c9f5f.firebaseapp.com/"),

                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        let laterAction = UIAlertAction(title: "あとで", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(laterAction)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    //表示中の最上位のViewControllerを取得
    private func getTopViewController(_ viewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(navigationController.visibleViewController)
        } else if let tabBarController = viewController as? UITabBarController, let selected = tabBarController.selectedViewController {
            return getTopViewController(selected)
        } else if let presented = viewController?.presentedViewController {
            return getTopViewController(presented)
        } else {
            return viewController
        }
    }
}

