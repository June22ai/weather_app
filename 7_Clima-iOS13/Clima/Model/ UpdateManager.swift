//
// UpdateManager.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/05/17.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import Combine
import FirebaseRemoteConfig
import UIKit
//強制アップデートに関する処理を担当するクラス
final class UpdateCheckManager {

    static let shared = UpdateCheckManager()
    //Firebase Remote Configとの通信とパラメータ取得
    private let remoteConfigProvider = FirebaseRemoteConfigProvider()
    private var cancellable: AnyCancellable?

    private init() {}

    func setup() {
        observeApplicationDidBecomeActive()
    }
    //UpdateCheckManagerでdidBecomeActiveを監視
    // アプリがActiveになった際にアップデートチェック
    //FirebaseRemoteConfigProviderにFirebaseのコンソールで設定したパラメータを取ってきてもらう
    private func observeApplicationDidBecomeActive() {
        cancellable = NotificationCenter.Publisher(center: .default, name: UIApplication.didBecomeActiveNotification, object: nil)
            .sink(receiveValue: { [weak self] _ in
                FirebaseRemoteConfigProvider().fetchConfig(completion: {
                    self?.forceUpdateIfNeeded()
                })
            })
    }

    // requireForceUpdateがtrueかつ現在のバージョンが最新のバージョンと異なる場合に強制アップデート
    private func forceUpdateIfNeeded() {
        let localVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        //Firebase Remote Configのパラメータ名を定義
        let requireForceUpdate = remoteConfigProvider.getConfig(key: .forceUpdateRequired).boolValue

        if requireForceUpdate,
           let currentVersionString = remoteConfigProvider.getConfig(key: .currentVersion).stringValue,
           localVersionString != currentVersionString
        {
            guard let storeUrlString = remoteConfigProvider.getConfig(key: .storeUrl).stringValue,
                  let _ = URL(string: storeUrlString)
            else {
                return
            }
            // 強制アップデートのアラートを出す
        }
    }
}

