//
//  CheckInEntity.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/23.
//

import Foundation

struct CheckInEntity: Hashable, Identifiable {
    let pilgrimageCode: String
    // TODO: UUID→Firebase Auth ID 移行完了後、レガシーデータがなくなった時点で非オプショナルにする
    let checkedInAt: Date?
    let memo: String?

    var id: String { pilgrimageCode }
}
