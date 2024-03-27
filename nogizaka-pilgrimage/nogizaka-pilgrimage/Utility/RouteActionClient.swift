//
//  RouteActionClient.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/27.
//

import ComposableArchitecture
import Dependencies
import Foundation

public struct RouteActionClient {
    public var viewOnMap: @Sendable (_ latitude: String, _ longitude: String) async -> Void
    public var viewOnGoogleMaps: @Sendable (_ latitude: String, _ longitude: String) async -> Void
}

extension RouteActionClient: DependencyKey {
    public static var liveValue = Self(
        viewOnMap: { latitude, longitude in
            @Dependency(\.openURL) var openURL
            let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=r")!
            await openURL.callAsFunction(url)
        },
        viewOnGoogleMaps: { latitude,longitude in
            @Dependency(\.openURL) var openURL
            let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)")!
            await openURL.callAsFunction(url)
        }
    )
}

extension RouteActionClient: TestDependencyKey {
    public static let previewValue = Self(
        viewOnMap: { lat,lon in },
        viewOnGoogleMaps: { lat,lon in }
    )
}

extension DependencyValues {
  public var routeActionClient: RouteActionClient {
    get { self[RouteActionClient.self] }
    set { self[RouteActionClient.self] = newValue }
  }
}
