//
//  FavoriteRepository.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct FavoriteRepository {
    var fetchFavorites: @Sendable () async throws -> [PilgrimageEntity]
    var isFavorited: @Sendable (_ code: String) async throws -> Bool
    var addFavorite: @Sendable (_ pilgrimage: PilgrimageEntity) async throws -> Void
    var removeFavorite: @Sendable (_ pilgrimage: PilgrimageEntity) async throws -> Void
}
