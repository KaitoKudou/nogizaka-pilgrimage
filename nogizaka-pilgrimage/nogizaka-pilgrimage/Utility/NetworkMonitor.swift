//
//  NetworkMonitor.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/21.
//

import Dependencies
import Foundation

public struct NetworkMonitor{
    public var monitorNetwork: @Sendable () async throws -> Void
}

extension NetworkMonitor: DependencyKey {
    public static var liveValue = Self(
        monitorNetwork: {
            let (data, response) = try await URLSession.shared.data(from: URL(string: "https://www.google.com")!)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }

            if httpResponse.statusCode != 200 {
                throw APIError.networkError
            }
        }
    )
}

extension NetworkMonitor: TestDependencyKey {
    public static let previewValue = Self(
        monitorNetwork: {}
    )
}

extension DependencyValues {
  public var networkMonitor: NetworkMonitor {
    get { self[NetworkMonitor.self] }
    set { self[NetworkMonitor.self] = newValue }
  }
}
