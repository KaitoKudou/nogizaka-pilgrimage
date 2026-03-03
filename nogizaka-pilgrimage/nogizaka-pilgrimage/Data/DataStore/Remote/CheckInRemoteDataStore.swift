//
//  CheckInRemoteDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import FirebaseFirestore
import UIKit

@DependencyClient
struct CheckInRemoteDataStore {
    var fetchAll: () async throws -> [PilgrimageInformation]
    var exists: (_ name: String) async throws -> Bool
    var add: (_ pilgrimage: PilgrimageInformation) async throws -> Void
}

extension CheckInRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchAll: {
                let snapshot = try await collectionRef().getDocuments()
                return try snapshot.documents.map { try $0.data(as: PilgrimageInformation.self) }
            },
            exists: { name in
                let snapshot = try await collectionRef().getDocuments()
                return snapshot.documents.contains { $0.documentID == name }
            },
            add: { pilgrimage in
                let ref = await collectionRef().document(pilgrimage.name)
                try ref.setData(from: pilgrimage)
            }
        )
    }()

    private static func collectionRef() async -> CollectionReference {
        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        return Firestore.firestore()
            .collection("checked-in-list")
            .document(uuid)
            .collection("list")
    }
}
