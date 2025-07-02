//
//  ContentView.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/04/19.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ローカル通知デモ")
                .font(.title)

            Button("通知を送る") {
                print("🔘 ボタンが押されました")
                requestNotificationPermission()
                scheduleNotification()
            }
        }
        .padding()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知の許可がされました")
            } else {
                print("❌ 通知が拒否されました")
            }
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "これはローカル通知です。"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ 通知スケジュールエラー: \(error.localizedDescription)")
            } else {
                print("✅ 通知がスケジュールされました")
            }
        }
    }
}
