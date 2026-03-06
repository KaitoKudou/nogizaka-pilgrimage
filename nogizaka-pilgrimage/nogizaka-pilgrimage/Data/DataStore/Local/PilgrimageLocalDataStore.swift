//
//  PilgrimageLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
struct PilgrimageLocalDataStore {
    var getAll: @Sendable () async throws -> [PilgrimageObject]?
    var save: @Sendable (_ dtos: [PilgrimageDTO]) async throws -> Void
}

extension PilgrimageLocalDataStore: DependencyKey {
    static let liveValue: Self = {
        @Dependency(SwiftDataClient.self) var swiftDataClient
        @Dependency(\.date) var date
        let sortByCode = SortDescriptor(\PilgrimageObject.code)

        return .init(
            getAll: {
                let context = ModelContext(try swiftDataClient.container())
                let descriptor = FetchDescriptor<PilgrimageObject>(sortBy: [sortByCode])
                let objects = try context.fetch(descriptor)
                guard !objects.isEmpty else { return nil }

                let ttl: TimeInterval = 24 * 60 * 60
                let oldestFetchedAt = objects.map(\.fetchedAt).min() ?? .distantPast
                guard date.now.timeIntervalSince(oldestFetchedAt) < ttl else { return nil }

                return objects
            },
            save: { dtos in
                let context = ModelContext(try swiftDataClient.container())
                try context.delete(model: PilgrimageObject.self)
                let now = date.now
                for dto in dtos {
                    context.insert(PilgrimageObject(from: dto, fetchedAt: now))
                }
                try context.save()
            }
        )
    }()
}
