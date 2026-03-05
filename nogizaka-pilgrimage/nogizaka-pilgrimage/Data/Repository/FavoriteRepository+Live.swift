//
//  FavoriteRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies

extension FavoriteRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(FavoriteLocalDataStore.self) var localDataStore
        @Dependency(PilgrimageLocalDataStore.self) var pilgrimageLocalDataStore

        return .init(
            fetchFavorites: {
                do {
                    let codes = try await localDataStore.getAll()
                    guard let objects = try await pilgrimageLocalDataStore.getAll() else {
                        return []
                    }
                    let codeSet = Set(codes)
                    return objects.filter { codeSet.contains($0.code) }.map { $0.toDomain() }
                } catch {
                    throw APIError.unknownError
                }
            },
            isFavorited: { code in
                do {
                    return try await localDataStore.contains(code)
                } catch {
                    throw APIError.unknownError
                }
            },
            addFavorite: { pilgrimage in
                do {
                    try await localDataStore.add(pilgrimage.code)
                } catch {
                    throw APIError.unknownError
                }
            },
            removeFavorite: { pilgrimage in
                do {
                    try await localDataStore.remove(pilgrimage.code)
                } catch {
                    throw APIError.unknownError
                }
            }
        )
    }()
}
