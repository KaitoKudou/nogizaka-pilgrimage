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
    var checkedInAt: Date

    init(pilgrimageCode: String, checkedInAt: Date = .now) {
        self.pilgrimageCode = pilgrimageCode
        self.checkedInAt = checkedInAt
    }
}
