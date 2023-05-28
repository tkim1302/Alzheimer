//
//  AppDelegate.swift
//  Alzheimer
//
//  Created by 김태영 on 2023/05/22.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func registerForPushNotifications() {
        // 1 - UNUserNotificationCenter는 푸시 알림을 포함하여 앱의 모든 알림 관련 활동을 처리합니다.
        UNUserNotificationCenter.current()
        // 2 -알림을 표시하기 위한 승인을 요청합니다. 전달된 옵션은 앱에서 사용하려는 알림 유형을 나타냅니다. 여기에서 알림(alert), 소리(sound) 및 배지(badge)를 요청합니다.
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                // 3 - 완료 핸들러는 인증이 성공했는지 여부를 나타내는 Bool을 수신합니다. 인증 결과를 표시합니다.
                print("Permission granted: \(granted)")
                // 추가
                guard granted else { return }
                self.getNotificationSettings()
            }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

}

