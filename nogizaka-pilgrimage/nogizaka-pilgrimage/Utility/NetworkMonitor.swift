//
//  NetworkMonitor.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/21.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct NetworkMonitor {
    var monitorNetwork: @Sendable () async throws -> Void
}

extension NetworkMonitor: DependencyKey {
    static var liveValue = Self(
        monitorNetwork: {
            let (_, response) = try await URLSession.shared.data(from: URL(string: "https://www.google.com")!)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }

            if httpResponse.statusCode != 200 {
                throw APIError.networkError
            }
        }
    )
}
