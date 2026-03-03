//
//  FavoriteRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import FirebaseFirestore

extension FavoriteRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(FavoriteRemoteDataStore.self) var remoteDataStore
        @Dependency(FavoriteLocalDataStore.self) var localDataStore

        return .init(
            fetchFavorites: {
                do {
                    let result = try await remoteDataStore.fetchAll()
                    await localDataStore.setAll(result)
                    return result
                } catch {
                    throw mapError(error, to: .fetchFavoritePilgrimagesError)
                }
            },
            isFavorited: { name in
                if let cached = await localDataStore.getAll() {
                    return cached.contains { $0.name == name }
                }
                do {
                    let result = try await remoteDataStore.fetchAll()
                    await localDataStore.setAll(result)
                    return result.contains { $0.name == name }
                } catch {
                    throw mapError(error, to: .fetchFavoritePilgrimagesError)
                }
            },
            addFavorite: { pilgrimage in
                do {
                    try await remoteDataStore.add(pilgrimage)
                    await localDataStore.add(pilgrimage)
                } catch {
                    throw mapError(error, to: .updateFavoritePilgrimagesError)
                }
            },
            removeFavorite: { pilgrimage in
                do {
                    try await remoteDataStore.remove(pilgrimage.name)
                    await localDataStore.remove(pilgrimage.id)
                } catch {
                    throw mapError(error, to: .updateFavoritePilgrimagesError)
                }
            }
        )
    }()

    private static func mapError(_ error: Error, to apiError: APIError) -> APIError {
        if (error as NSError).domain == FirestoreErrorDomain {
            return apiError
        }
        return .unknownError
    }
}
