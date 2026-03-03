//
//  AppConfigRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import FirebaseFirestore

extension AppConfigRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AppConfigRemoteDataStore.self) var remoteDataStore

        return .init(
            fetchUpdateInfo: {
                do {
                    return try await remoteDataStore.fetchUpdateInfo()
                } catch {
                    if (error as NSError).domain == FirestoreErrorDomain {
                        throw APIError.networkError
                    }
                    throw APIError.unknownError
                }
            }
        )
    }()
}
