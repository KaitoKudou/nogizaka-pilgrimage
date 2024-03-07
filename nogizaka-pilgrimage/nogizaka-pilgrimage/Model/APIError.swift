//
//  APIError.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/29.
//

import Foundation

enum APIError: Error {
    case fetchPilgrimagesError
    case fetchFavoritePilgrimagesError
    case updateFavoritePilgrimagesError
    case unknownError
}

extension APIError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .fetchPilgrimagesError:
            return R.string.localizable.alert_fetch_pilgrimages()
        case .fetchFavoritePilgrimagesError:
            return R.string.localizable.alert_fetch_favorite_pilgrimages()
        case .updateFavoritePilgrimagesError:
            return R.string.localizable.alert_update_favorite_pilgrimages()
        case .unknownError:
            return R.string.localizable.alert_unknown()
        }
    }
}
