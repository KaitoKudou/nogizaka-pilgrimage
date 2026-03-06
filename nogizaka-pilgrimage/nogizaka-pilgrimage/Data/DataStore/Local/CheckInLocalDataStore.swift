//
//  CheckInLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
struct CheckInLocalDataStore {
    var getAll: @Sendable () async throws -> [String]?
    var setAll: @Sendable (_ codes: [String]) async throws -> Void
    var add: @Sendable (_ code: String) async throws -> Void
    var contains: @Sendable (_ code: String) async throws -> Bool
}

extension CheckInLocalDataStore: DependencyKey {
    private static let hasLoadedKey = "hasLoadedCheckInsOnce"

    static let liveValue: Self = {
        @Dependency(SwiftDataClient.self) var swiftDataClient
        let sortByCheckedInAt = SortDescriptor(\CheckInObject.checkedInAt)

        return .init(
            getAll: {
                guard UserDefaults.standard.bool(forKey: hasLoadedKey) else { return nil }
                let context = ModelContext(try swiftDataClient.container())
                let descriptor = FetchDescriptor<CheckInObject>(
                    sortBy: [sortByCheckedInAt]
                )
                let objects = try context.fetch(descriptor)
                return objects.map(\.pilgrimageCode)
            },
            setAll: { codes in
                let context = ModelContext(try swiftDataClient.container())
                try context.delete(model: CheckInObject.self)
                for code in codes {
                    context.insert(CheckInObject(pilgrimageCode: code))
                }
                try context.save()
                UserDefaults.standard.set(true, forKey: hasLoadedKey)
            },
            add: { code in
                let context = ModelContext(try swiftDataClient.container())
                context.insert(CheckInObject(pilgrimageCode: code))
                try context.save()
            },
            contains: { code in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<CheckInObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                let matched = try context.fetch(descriptor)
                return !matched.isEmpty
            }
        )
    }()
}
