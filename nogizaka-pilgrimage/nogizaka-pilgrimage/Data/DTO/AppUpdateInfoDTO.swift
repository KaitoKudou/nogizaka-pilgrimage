//
//  AppUpdateInfoDTO.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/05.
//

import Foundation

struct AppUpdateInfoDTO: Decodable, Hashable {
    let targetVersion: String
    let isForce: Bool
    let title: String
    let message: String
    let appStoreURL: String

    enum CodingKeys: String, CodingKey {
        case targetVersion = "target_version"
        case isForce = "is_force"
        case title
        case message
        case appStoreURL = "app_store_url"
    }
}
