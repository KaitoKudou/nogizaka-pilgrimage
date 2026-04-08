//
//  CheckInLocalDataStore.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
struct CheckInLocalDataStore {
    /// 全チェックイン記録を取得する（未ロード時はnil）
    var getAll: @Sendable () async throws -> [CheckInObject]?
    /// Remoteから取得した記録でローカルキャッシュを全置換する
    var setAll: @Sendable (_ records: [CheckInEntity]) async throws -> Void
    /// 新規チェックイン記録を追加する
    var add: @Sendable (_ code: String, _ checkedInAt: Date, _ memo: String?) async throws -> Void
    /// 指定コードのチェックイン記録が存在するか判定する
    var contains: @Sendable (_ code: String) async throws -> Bool
    /// 指定コードのチェックイン記録を1件取得する
    var get: @Sendable (_ code: String) async throws -> CheckInObject?
    /// 指定コードの訪問日時を更新する
    var updateCheckedInAt: @Sendable (_ code: String, _ newDate: Date) async throws -> Void
    /// 指定コードのメモを更新する（nilで削除）
    var updateMemo: @Sendable (_ code: String, _ memo: String?) async throws -> Void
}

extension CheckInLocalDataStore: DependencyKey {
    static let liveValue: Self = {
        @Dependency(SwiftDataClient.self) var swiftDataClient
        let sortByCheckedInAt = SortDescriptor(\CheckInObject.checkedInAt)

        return .init(
            getAll: {
                guard UserDefaults.standard.bool(forKey: UserDefaultsKey.hasLoadedCheckInsOnce.rawValue) else { return nil }
                let context = ModelContext(try swiftDataClient.container())
                let descriptor = FetchDescriptor<CheckInObject>(
                    sortBy: [sortByCheckedInAt]
                )
                return try context.fetch(descriptor)
            },
            setAll: { records in
                let context = ModelContext(try swiftDataClient.container())
                try context.delete(model: CheckInObject.self)
                for record in records {
                    context.insert(
                        CheckInObject(
                            pilgrimageCode: record.pilgrimageCode,
                            checkedInAt: record.checkedInAt,
                            memo: record.memo
                        )
                    )
                }
                try context.save()
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasLoadedCheckInsOnce.rawValue)
            },
            add: { code, checkedInAt, memo in
                let context = ModelContext(try swiftDataClient.container())
                context.insert(
                    CheckInObject(pilgrimageCode: code, checkedInAt: checkedInAt, memo: memo)
                )
                try context.save()
            },
            contains: { code in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<CheckInObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                let matched = try context.fetch(descriptor)
                return !matched.isEmpty
            },
            get: { code in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<CheckInObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                return try context.fetch(descriptor).first
            },
            updateCheckedInAt: { code, newDate in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<CheckInObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                guard let object = try context.fetch(descriptor).first else { return }
                object.checkedInAt = newDate
                try context.save()
            },
            updateMemo: { code, memo in
                let context = ModelContext(try swiftDataClient.container())
                var descriptor = FetchDescriptor<CheckInObject>(
                    predicate: #Predicate { $0.pilgrimageCode == code }
                )
                descriptor.fetchLimit = 1
                guard let object = try context.fetch(descriptor).first else { return }
                object.memo = memo
                try context.save()
            }
        )
    }()
}
