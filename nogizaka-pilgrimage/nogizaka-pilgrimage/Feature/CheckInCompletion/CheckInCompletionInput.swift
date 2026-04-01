//
//  CheckInCompletionInput.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/31.
//

import Foundation

struct CheckInCompletionInput: Identifiable {
    let id = UUID()
    let pilgrimage: PilgrimageEntity
    let checkedInAt: Date
    let isOnline: Bool
}
