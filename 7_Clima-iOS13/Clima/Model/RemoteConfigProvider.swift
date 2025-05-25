//
//  RemoteConfigProvider.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/05/17.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import Firebase
// Firebaseのコンソールで設定したパラメータ名に対応
enum ConfigKey: String {
    case currentVersion = "current_version"
    case forceUpdateRequired = "require_force_update"
    case storeUrl = "app_store_url"

    static func makeDefaults() -> [String: Any] {
        [
            currentVersion.rawValue: "",
            forceUpdateRequired.rawValue: false,
            storeUrl.rawValue: ""
        ]
    }
}

final class FirebaseRemoteConfigProvider {
    private let remoteConfig = RemoteConfig.remoteConfig()

    // パラメータを取ってくる
    func fetchConfig(completion: (() -> Void)? = nil) {

        // 取得するパラメータのデフォルトを設定
        remoteConfig.setDefaults(ConfigKey.makeDefaults() as? [String: NSObject])
        
        // FetchとActivateを一括で行う
        remoteConfig.fetchAndActivate(completionHandler: { status, error in
            switch status {
            case .successUsingPreFetchedData, .successFetchedFromRemote:
                completion?()
            case .error:
                if let error = error {
                    print(error.localizedDescription)
                }
            @unknown default: fatalError()
            }
        })
    }

    // RemoteConfigから取ってきたパラメータを取得
    func getConfig(key: ConfigKey) -> RemoteConfigValue {
        remoteConfig.configValue(forKey: key.rawValue)
    }
}
