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
    var fetchFavorites: () async throws -> [PilgrimageInformation]
    var isFavorited: (_ name: String) async throws -> Bool
    var addFavorite: (_ pilgrimage: PilgrimageInformation) async throws -> Void
    var removeFavorite: (_ pilgrimage: PilgrimageInformation) async throws -> Void
}
