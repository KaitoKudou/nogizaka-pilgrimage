//
//  nogizaka_pilgrimageApp.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2022/12/27.
//

import FirebaseCore
import GoogleMobileAds
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        return true
    }
}

@main
struct nogizaka_pilgrimageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
        }
    }
}
