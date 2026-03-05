//
//  FavoriteRemoteDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import FirebaseFirestore
import UIKit

// MARK: - DEPRECATED: マイグレーション用に残す。次リリースで削除予定。
@DependencyClient
struct FavoriteRemoteDataStore {
    var fetchAll: () async throws -> [PilgrimageDTO]
}

extension FavoriteRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchAll: {
                let snapshot = try await collectionRef().getDocuments()
                return try snapshot.documents.map { try $0.data(as: PilgrimageDTO.self) }
            }
        )
    }()

    private static func collectionRef() async -> CollectionReference {
        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        return Firestore.firestore()
            .collection("favorite-list")
            .document(uuid)
            .collection("list")
    }
}
