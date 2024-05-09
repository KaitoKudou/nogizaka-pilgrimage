//
//  AppUpdateInformation.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/06.
//

import Foundation

struct AppUpdateInformation: Decodable, Hashable {
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
