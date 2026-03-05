//
//  RouteActionClient.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/27.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct RouteActionClient {
    var viewOnMap: @Sendable (_ latitude: String, _ longitude: String) async -> Void
    var viewOnGoogleMaps: @Sendable (_ latitude: String, _ longitude: String) async -> Void
}

extension RouteActionClient: DependencyKey {
    static var liveValue = Self(
        viewOnMap: { latitude, longitude in
            @Dependency(\.openURL) var openURL
            let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=r")!
            await openURL.callAsFunction(url)
        },
        viewOnGoogleMaps: { latitude, longitude in
            @Dependency(\.openURL) var openURL
            let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)")!
            await openURL.callAsFunction(url)
        }
    )
}
