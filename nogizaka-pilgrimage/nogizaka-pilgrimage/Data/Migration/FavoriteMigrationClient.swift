//
//  FavoriteMigrationClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import AppLogger
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct FavoriteMigrationClient {
    var migrateIfNeeded: @Sendable () async -> Void
}

extension FavoriteMigrationClient: DependencyKey {
    static let liveValue: Self = {
        @Dependency(FavoriteRemoteDataStore.self) var remoteDataStore
        @Dependency(FavoriteLocalDataStore.self) var localDataStore

        return .init(
            migrateIfNeeded: {
                guard !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasMigratedFavoritesToLocal.rawValue) else { return }
                do {
                    let dtos = try await remoteDataStore.fetchAll()
                    let codes = dtos.map(\.code)
                    try await localDataStore.setAll(codes)
                    UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasMigratedFavoritesToLocal.rawValue)
                } catch {
                    #log(.error, "Favorite migration failed: \(error.localizedDescription)")
                }
            }
        )
    }()
}
