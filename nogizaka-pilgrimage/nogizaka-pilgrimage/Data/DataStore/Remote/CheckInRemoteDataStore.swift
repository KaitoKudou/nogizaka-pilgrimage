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
    /// 全チェックイン記録を取得する
    var fetchAll: @Sendable () async throws -> [CheckInDTO]
    /// 新規チェックイン記録を追加する
    var add: @Sendable (_ dto: CheckInDTO) async throws -> Void
    /// 指定コードの訪問日時を更新する
    var updateCheckedInAt: @Sendable (_ code: String, _ newDate: Date) async throws -> Void
    /// 指定コードのメモを更新する（nilでフィールド削除）
    var updateMemo: @Sendable (_ code: String, _ memo: String?) async throws -> Void
}

extension CheckInRemoteDataStore: DependencyKey {
    static let rootCollection = "checked-in-list"
    static let listSubcollection = "list"

    static let liveValue: Self = {
        return .init(
            fetchAll: {
                do {
                    let snapshot = try await collectionRef().getDocuments()
                    return try snapshot.documents.map { try $0.data(as: CheckInDTO.self) }
                } catch {
                    throw APIError.fetchError
                }
            },
            add: { dto in
                do {
                    let ref = await collectionRef().document(dto.pilgrimageDTO.code)
                    try ref.setData(from: dto)
                } catch {
                    throw APIError.updateError
                }
            },
            updateCheckedInAt: { code, newDate in
                do {
                    let ref = await collectionRef().document(code)
                    try await ref.updateData(["checked_in_at": Timestamp(date: newDate)])
                } catch {
                    throw APIError.updateError
                }
            },
            updateMemo: { code, memo in
                do {
                    let ref = await collectionRef().document(code)
                    if let memo {
                        try await ref.updateData(["memo": memo])
                    } else {
                        try await ref.updateData(["memo": FieldValue.delete()])
                    }
                } catch {
                    throw APIError.updateError
                }
            }
        )
    }()

    private static func collectionRef() async -> CollectionReference {
        @Dependency(AuthRepository.self) var authRepository
        let documentId: String
        if let user = authRepository.currentUser() {
            documentId = user.uid
        } else {
            documentId = await UIDevice.current.identifierForVendor!.uuidString
        }
        return Firestore.firestore()
            .collection(rootCollection)
            .document(documentId)
            .collection(listSubcollection)
    }
}
