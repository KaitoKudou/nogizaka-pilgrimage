//
//  SwiftDataClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
struct SwiftDataClient {
    var container: @Sendable () throws -> ModelContainer
}

extension SwiftDataClient: DependencyKey {
    static let liveValue: Self = {
        let result: Result<ModelContainer, Error> = Result {
            let schema = Schema([
                PilgrimageObject.self,
                FavoriteObject.self,
                CheckInObject.self,
            ])
            let config = ModelConfiguration(
                "NogizakaPilgrimage",
                schema: schema,
                isStoredInMemoryOnly: false
            )
            return try ModelContainer(for: schema, configurations: [config])
        }
        return .init(container: { try result.get() })
    }()
}
