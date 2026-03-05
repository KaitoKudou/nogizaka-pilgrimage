//
//  AppConfigRemoteDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import FirebaseFirestore

@DependencyClient
struct AppConfigRemoteDataStore {
    var fetchUpdateInfo: () async throws -> AppUpdateInformation
}

extension AppConfigRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchUpdateInfo: {
                do {
                    return try await Firestore.firestore()
                        .collection("configure")
                        .document("update")
                        .getDocument()
                        .data(as: AppUpdateInformation.self)
                } catch {
                    throw APIError.networkError
                }
            }
        )
    }()
}
