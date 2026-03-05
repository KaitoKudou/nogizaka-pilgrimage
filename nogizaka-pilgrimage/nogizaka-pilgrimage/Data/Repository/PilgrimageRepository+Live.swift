//
//  PilgrimageRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies

extension PilgrimageRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(PilgrimageRemoteDataStore.self) var remoteDataStore
        @Dependency(PilgrimageLocalDataStore.self) var localDataStore

        return .init(
            fetchAllPilgrimages: {
                do {
                    if let cached = try await localDataStore.getAll() {
                        return cached.map { $0.toDomain() }
                    }
                    let dtos = try await remoteDataStore.fetchAll()
                    try await localDataStore.save(dtos)
                    guard let objects = try await localDataStore.getAll() else {
                        return dtos.map { PilgrimageObject(from: $0).toDomain() }
                    }
                    return objects.map { $0.toDomain() }
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            }
        )
    }()
}
