//
//  ShakeDetector.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

#if DEBUG
import Dependencies
import Foundation
import SwiftUI
import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            @Dependency(\.notificationCenter) var notificationCenter
            notificationCenter.post(name: Constants.Notification.deviceDidShake, object: nil)
        }
    }
}

struct OnShakeModifier: ViewModifier {
    @Dependency(\.notificationCenter) private var notificationCenter

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(notificationCenter.publisher(for: Constants.Notification.deviceDidShake)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(OnShakeModifier(action: action))
    }
}
#endif
