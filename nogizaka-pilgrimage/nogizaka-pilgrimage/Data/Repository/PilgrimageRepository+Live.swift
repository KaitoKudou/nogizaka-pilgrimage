//
//  PilgrimageRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import FirebaseFirestore

extension PilgrimageRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(PilgrimageRemoteDataStore.self) var remoteDataStore

        return .init(
            fetchAllPilgrimages: {
                do {
                    return try await remoteDataStore.fetchAll()
                } catch {
                    throw mapError(error, to: .fetchPilgrimagesError)
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
