//
//  SafariEffect.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/29.
//

import Dependencies

#if canImport(SafariServices) && canImport(SwiftUI)
import SafariServices
import SwiftUI

extension DependencyValues {
    /// SFSafariViewController で URL を開く依存関係
    ///
    /// iOSではUIKitコンテキストでSFSafariViewControllerを使用する
    /// そうでない場合は、EnvironmentValuesで openURL を使用します。
    ///
    /// - SeeAlso: https://sarunw.com/posts/sfsafariviewcontroller-in-swiftui/
    @available(iOS 15, macOS 11, tvOS 14, watchOS 7, *)
    public var safari: SafariEffect {
        get { self[SafariKey.self] }
        set { self[SafariKey.self] = newValue }
    }
}

@available(iOS 15, macOS 11, tvOS 14, watchOS 7, *)
private enum SafariKey: DependencyKey {
    static let liveValue = SafariEffect { url in
        let stream = AsyncStream<Bool> { continuation in
            let task = Task { @MainActor in
                #if os(iOS)
                let vc = SFSafariViewController(url: url)
                UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
                continuation.yield(true)
                continuation.finish()
                #else
                EnvironmentValues().openURL(url)
                continuation.yield(true)
                continuation.finish()
                #endif
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
        return await stream.first(where: { _ in true }) ?? false
    }
    static let testValue = SafariEffect { _ in
        XCTFail(#"Unimplemented: @Dependency(\.safari)"#)
        return false
    }
}

public struct SafariEffect {
    private let handler: @Sendable (URL) async -> Bool

    public init(handler: @escaping @Sendable (URL) async -> Bool) {
        self.handler = handler
    }

    @available(watchOS, unavailable)
    @discardableResult
    public func callAsFunction(_ url: URL) async -> Bool {
        await self.handler(url)
    }

    @_disfavoredOverload
    public func callAsFunction(_ url: URL) async {
        _ = await self.handler(url)
    }
}
#endif

#if canImport(UIKit)
import UIKit

extension UIApplication {
    @available(iOS 15.0, *)
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
#endif
