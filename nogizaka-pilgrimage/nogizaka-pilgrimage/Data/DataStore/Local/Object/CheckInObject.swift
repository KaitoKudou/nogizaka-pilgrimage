//
//  CheckInObject.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Foundation
import SwiftData

@Model
final class CheckInObject {
    @Attribute(.unique) var pilgrimageCode: String
    // TODO: UUID→Firebase Auth ID 移行完了後、レガシーデータがなくなった時点で非オプショナルにする
    var checkedInAt: Date?
    var memo: String?

    init(pilgrimageCode: String, checkedInAt: Date? = nil, memo: String? = nil) {
        self.pilgrimageCode = pilgrimageCode
        self.checkedInAt = checkedInAt
        self.memo = memo
    }
}
