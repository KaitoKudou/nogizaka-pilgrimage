//
//  PilgrimageRemoteDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import AppLogger
import Dependencies
import DependenciesMacros
import FirebaseFirestore

@DependencyClient
struct PilgrimageRemoteDataStore {
    var fetchAll: @Sendable () async throws -> [PilgrimageDTO]
}

extension PilgrimageRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchAll: {
                do {
                    let snapshot = try await Firestore.firestore()
                        .collection("pilgrimage-list")
                        .getDocuments()
                    return try snapshot.documents.map { try $0.data(as: PilgrimageDTO.self) }
                } catch {
                    #log(.error, "fetch error: \(error)")
                    throw APIError.fetchError
                }
            }
        )
    }()
}
