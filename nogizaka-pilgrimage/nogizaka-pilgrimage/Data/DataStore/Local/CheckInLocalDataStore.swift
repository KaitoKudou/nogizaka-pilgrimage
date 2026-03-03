//
//  CheckInLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct CheckInLocalDataStore {
    var getAll: () async -> [PilgrimageInformation]?
    var setAll: (_ pilgrimages: [PilgrimageInformation]) async -> Void
    var add: (_ pilgrimage: PilgrimageInformation) async -> Void
}

extension CheckInLocalDataStore: DependencyKey {
    static let liveValue: Self = {
        let storage = CheckInLocalStorage()
        return .init(
            getAll: { await storage.getAll() },
            setAll: { await storage.setAll($0) },
            add: { await storage.add($0) }
        )
    }()
}

private actor CheckInLocalStorage {
    private var pilgrimages: [PilgrimageInformation]?

    func getAll() -> [PilgrimageInformation]? { pilgrimages }
    func setAll(_ items: [PilgrimageInformation]) { pilgrimages = items }
    func add(_ item: PilgrimageInformation) { pilgrimages?.append(item) }
}
