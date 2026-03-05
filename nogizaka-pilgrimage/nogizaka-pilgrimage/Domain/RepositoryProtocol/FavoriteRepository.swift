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
    var fetchFavorites: () async throws -> [PilgrimageEntity]
    var isFavorited: (_ code: String) async throws -> Bool
    var addFavorite: (_ pilgrimage: PilgrimageEntity) async throws -> Void
    var removeFavorite: (_ pilgrimage: PilgrimageEntity) async throws -> Void
}
