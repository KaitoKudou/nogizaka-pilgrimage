//
//  FavoriteLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
struct FavoriteLocalDataStore {
    var getAll: @Sendable () async throws -> [String]
    // TODO: マイグレーション完了後に削除する
    var setAll: @Sendable (_ codes: [String]) async throws -> Void
    var add: @Sendable (_ code: String) async throws -> Void
    var remove: @Sendable (_ code: String) async throws -> Void
    var contains: @Sendable (_ code: String) async throws -> Bool
}

extension FavoriteLocalDataStore: DependencyKey {
    static let liveValue: Self = {
        @Dependency(SwiftDataClient.self) var swiftDataClient
        let sortByAddedAt = SortDescriptor(\FavoriteObject.addedAt)

        return .init(
            getAll: {
                let context = ModelContext(try swiftDataClient.container())
                let descriptor = FetchDescriptor<FavoriteObject>(
                    sortBy: [sortByAddedAt]
                )
                let objects = try context.fetch(descriptor)
                return objects.map(\.pilgrimageCode)
            },
            setAll: { codes in
                let context = ModelContext(try swiftDataClient.container())
                try context.delete(model: FavoriteObject.self)
                for code in codes {
                    context.insert(FavoriteObject(pilgrimageCode: code))
                }
                try context.save()
            },
            add: { code in
                let context = ModelContext(try swiftDataClient.container())
                context.insert(FavoriteObject(pilgrimageCode: code))
                try context.save()
            },
            remove: { code in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<FavoriteObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                let matched = try context.fetch(descriptor)
                for object in matched {
                    context.delete(object)
                }
                try context.save()
            },
            contains: { code in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<FavoriteObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                let matched = try context.fetch(descriptor)
                return !matched.isEmpty
            }
        )
    }()
}
