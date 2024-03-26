//
//  APIError.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/29.
//

import Foundation

enum APIError: Error {
    case networkError
    case fetchPilgrimagesError
    case fetchFavoritePilgrimagesError
    case updateFavoritePilgrimagesError
    case fetchCheckedInError
    case updateCheckedInError
    case unknownError
}

extension APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .networkError:
            return R.string.localizable.alert_network()
        case .fetchPilgrimagesError:
            return R.string.localizable.alert_fetch_pilgrimages()
        case .fetchFavoritePilgrimagesError:
            return R.string.localizable.alert_fetch_favorite_pilgrimages()
        case .updateFavoritePilgrimagesError:
            return R.string.localizable.alert_update_favorite_pilgrimages()
        case .fetchCheckedInError:
            return R.string.localizable.alert_fetch_checked_in_pilgrimages()
        case .updateCheckedInError:
            return R.string.localizable.alert_update_checked_in_pilgrimages()
        case .unknownError:
            return R.string.localizable.alert_unknown()
        }
    }
}
