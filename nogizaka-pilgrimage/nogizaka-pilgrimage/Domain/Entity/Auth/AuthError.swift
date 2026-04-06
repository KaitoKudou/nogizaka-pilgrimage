//
//  AuthError.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import Foundation

enum AuthError: Error {
    case signInFailed
    case signOutFailed
    case missingIDToken
    case cancelled
}
