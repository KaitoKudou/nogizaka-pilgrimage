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
    var fetchAll: () async throws -> [PilgrimageDTO]
    var add: (_ dto: PilgrimageDTO) async throws -> Void
}

extension CheckInRemoteDataStore: DependencyKey {
    static let liveValue: Self = {
        return .init(
            fetchAll: {
                do {
                    let snapshot = try await collectionRef().getDocuments()
                    return try snapshot.documents.map { try $0.data(as: PilgrimageDTO.self) }
                } catch {
                    throw APIError.fetchError
                }
            },
            add: { dto in
                do {
                    let ref = await collectionRef().document(dto.code)
                    try ref.setData(from: dto)
                } catch {
                    throw APIError.updateError
                }
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
