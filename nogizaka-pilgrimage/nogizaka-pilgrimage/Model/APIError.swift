//
//  APIError.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/29.
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
            return R.string.localizable.alert_network()
        case .fetchError:
            return R.string.localizable.alert_fetch_error()
        case .updateError:
            return R.string.localizable.alert_update_error()
        case .unknownError:
            return R.string.localizable.alert_unknown()
        }
    }
}
