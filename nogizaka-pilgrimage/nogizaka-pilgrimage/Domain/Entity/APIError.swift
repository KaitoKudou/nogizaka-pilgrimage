//
//  APIError.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/05.
//

import Foundation

enum APIError: Error {
    case networkError
    case fetchError
    case updateError
    case unknownError
}

extension APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .networkError:
            return String(localized: .alertNetwork)
        case .fetchError:
            return String(localized: .alertFetchError)
        case .updateError:
            return String(localized: .alertUpdateError)
        case .unknownError:
            return String(localized: .alertUnknown)
        }
    }
}
