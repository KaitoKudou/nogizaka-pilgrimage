//
//  Constants.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/23.
//

import Foundation

enum Constants {
    /// メモの最大文字数
    static let memoMaxLength = 140

    enum Layout {
        enum Button {
            static let signInWithAppleHeight: CGFloat = 50
        }
    }

    enum UserDefaultsKey {
        static let lastSignInPromptVersion = "lastSignInPromptVersion"
    }

    #if DEBUG
    enum Notification {
        static let deviceDidShake = NSNotification.Name("deviceDidShake")
    }
    #endif
}

