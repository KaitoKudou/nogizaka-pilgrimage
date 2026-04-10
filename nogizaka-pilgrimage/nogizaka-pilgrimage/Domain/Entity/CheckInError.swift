//
//  CheckInError.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/23.
//

import Foundation

enum CheckInError: Error {
    case notNearby
    case memoTooLong
    case signInRequired
}
