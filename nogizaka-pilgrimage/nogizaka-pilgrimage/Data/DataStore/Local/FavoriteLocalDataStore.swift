//
//  FavoriteLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct FavoriteLocalDataStore {
    var getAll: () async -> [PilgrimageInformation]?
    var setAll: (_ pilgrimages: [PilgrimageInformation]) async -> Void
    var add: (_ pilgrimage: PilgrimageInformation) async -> Void
    var remove: (_ id: Int) async -> Void
}

extension FavoriteLocalDataStore: DependencyKey {
    static let liveValue: Self = {
        let storage = FavoriteLocalStorage()
        return .init(
            getAll: { await storage.getAll() },
            setAll: { await storage.setAll($0) },
            add: { await storage.add($0) },
            remove: { await storage.remove($0) }
        )
    }()
}

private actor FavoriteLocalStorage {
    private var pilgrimages: [PilgrimageInformation]?

    func getAll() -> [PilgrimageInformation]? { pilgrimages }
    func setAll(_ items: [PilgrimageInformation]) { pilgrimages = items }
    func add(_ item: PilgrimageInformation) { pilgrimages?.append(item) }
    func remove(_ id: Int) { pilgrimages?.removeAll { $0.id == id } }
}
