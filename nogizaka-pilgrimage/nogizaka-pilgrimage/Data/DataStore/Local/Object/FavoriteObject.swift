//
//  FavoriteObject.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Foundation
import SwiftData

@Model
final class FavoriteObject {
    @Attribute(.unique) var pilgrimageCode: String
    var addedAt: Date

    init(pilgrimageCode: String, addedAt: Date = .now) {
        self.pilgrimageCode = pilgrimageCode
        self.addedAt = addedAt
    }
}
