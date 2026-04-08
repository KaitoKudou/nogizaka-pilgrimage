//
//  CheckInMigrationClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/08.
//

import AppLogger
import Dependencies
import DependenciesMacros
import FirebaseFirestore
import Foundation
import UIKit

@DependencyClient
struct CheckInMigrationClient {
    var migrateIfNeeded: @Sendable () async -> Void
}

extension CheckInMigrationClient: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AuthRepository.self) var authRepository
        // UserDefaultsフラグの読み取りからFirestore書き込み完了までにタイムウィンドウがあり、
        // その間に別スレッドから呼ばれると同じデータが二重コピーされる。
        // インメモリフラグで排他制御し、同時実行を防ぐ。
        let isMigrating = LockIsolated(false)

        return .init(
            migrateIfNeeded: {
                let didStart = isMigrating.withValue { flag -> Bool in
                    guard !flag else { return false }
                    flag = true
                    return true
                }
                guard didStart else { return }
                defer { isMigrating.setValue(false) }

                guard !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasCompletedCheckInMigration.rawValue) else {
                    return
                }
                guard let user = authRepository.currentUser() else { return }
                guard let uuid = await UIDevice.current.identifierForVendor?.uuidString else { return }

                do {
                    let db = Firestore.firestore()
                    let root = CheckInRemoteDataStore.rootCollection
                    let sub = CheckInRemoteDataStore.listSubcollection

                    let sourceRef = db.collection(root).document(uuid).collection(sub)
                    let snapshot = try await sourceRef.getDocuments()

                    guard !snapshot.documents.isEmpty else {
                        UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasCompletedCheckInMigration.rawValue)
                        return
                    }

                    let destRef = db.collection(root).document(user.uid).collection(sub)
                    let batch = db.batch()
                    for doc in snapshot.documents {
                        batch.setData(doc.data(), forDocument: destRef.document(doc.documentID))
                    }
                    try await batch.commit()

                    UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasCompletedCheckInMigration.rawValue)
                } catch {
                    #log(.error, "Check-in migration failed: \(error.localizedDescription)")
                }
            }
        )
    }()
}
