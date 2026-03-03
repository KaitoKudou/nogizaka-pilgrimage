//
//  PilgrimageRemoteDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import FirebaseFirestore

@DependencyClient
struct PilgrimageRemoteDataStore {
    var fetchAll: () async throws -> [PilgrimageInformation]
}

extension PilgrimageRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchAll: {
                let snapshot = try await Firestore.firestore()
                    .collection("pilgrimage-list")
                    .getDocuments()
                return try snapshot.documents.map { try $0.data(as: PilgrimageInformation.self) }
            }
        )
    }()
}
